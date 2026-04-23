import json
import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient


with patch("google.cloud.pubsub_v1.PublisherClient"), \
     patch("google.cloud.secretmanager.SecretManagerServiceClient"), \
     patch("confluent_kafka.Consumer"):
    from cloude_run_service.main import app

client = TestClient(app)

@pytest.fixture
def mock_publisher():
    """Fixture to mock the Pub/Sub publisher instance in main.py."""
    with patch("cloude_run_service.main.publisher") as mocked_pub:
        yield mocked_pub

@pytest.fixture
def mock_consumer_class():
    """Fixture to mock the Kafka Consumer class."""
    with patch("cloude_run_service.main.Consumer") as mocked_cons:
        yield mocked_cons

@pytest.fixture
def mock_get_secret():
    """Fixture to mock Secret Manager calls in config.py."""
    with patch("config.Config.get_secret") as mocked_secret:
        mocked_secret.return_value = "mocked-secret-value"
        yield mocked_secret

def test_consume_batch_invalid_country():
    """Tests that an invalid country code returns a 400 error."""
    response = client.post("/consume/uk")
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid country code. Use 'us' or 'br'."

def test_consume_batch_no_messages(mock_consumer_class):
    """Tests the behavior when Kafka returns an empty batch."""
    # Setup mock consumer to return an empty list
    mock_instance = mock_consumer_class.return_value
    mock_instance.consume.return_value = []
    
    response = client.post("/consume/us")
    assert response.status_code == 200
    assert response.json()["message"] == "No new messages to consume."
    assert response.json()["count"] == 0

def test_consume_batch_us_success(mock_consumer_class, mock_publisher):
    """Tests successful processing and publishing of a US sales record."""
    mock_cons_instance = mock_consumer_class.return_value
    
    # Mock a Kafka message with valid US schema data
    mock_msg = MagicMock()
    mock_msg.error.return_value = None
    mock_msg.offset.return_value = 101
    mock_msg.value.return_value = json.dumps({
        "transaction_id": "TX123",
        "transaction_time": "2023-10-27T10:00:00Z",
        "store": "New York",
        "employee": "E001",
        "models_purchased": [{"line_num": 1, "model": "Model X", "model_price": 500.0}],
        "payment": {
            "card_information": {"card_number": "1111", "card_expires": "12/25"},
            "total": {"payment": 500.0, "currency": "USD"}
        }
    }).encode("utf-8")
    
    mock_cons_instance.consume.return_value = [mock_msg]
    
    # Mock Pub/Sub publish future
    mock_future = MagicMock()
    mock_publisher.publish.return_value = mock_future
    
    response = client.post("/consume/us")
    
    assert response.status_code == 200
    assert response.json()["processed_count"] == 1
    assert mock_publisher.publish.called

def test_consume_batch_validation_failure_routes_to_dlt(mock_consumer_class, mock_publisher):
    """Tests that malformed data is routed to the Dead Letter Topic (DLT)."""
    mock_cons_instance = mock_consumer_class.return_value
    
    mock_msg = MagicMock()
    mock_msg.error.return_value = None
    mock_msg.offset.return_value = 500
    mock_msg.value.return_value = b'{"invalid": "data"}'
    
    mock_cons_instance.consume.return_value = [mock_msg]
    
    response = client.post("/consume/us")
    
    assert response.status_code == 200
    assert response.json()["routed_to_dlt_count"] == 1
    assert mock_publisher.publish.called
