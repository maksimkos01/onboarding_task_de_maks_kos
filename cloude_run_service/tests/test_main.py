import pytest
from unittest.mock import patch, MagicMock

# --- CRITICAL: PATCH BEFORE IMPORTING APP ---
with patch("google.cloud.pubsub_v1.PublisherClient"), \
     patch("google.cloud.secretmanager.SecretManagerServiceClient"), \
     patch("confluent_kafka.Consumer"):
    
    from cloude_run_service.main import app
    from fastapi.testclient import TestClient

client = TestClient(app)

@pytest.fixture
def mock_kafka_consumer():
    with patch("cloude_run_service.main.Consumer") as mock:
        yield mock

@pytest.fixture
def mock_pubsub_publisher():
    with patch("cloude_run_service.main.publisher") as mock:
        yield mock

@pytest.fixture
def mock_kafka_consumer():
    with patch("cloude_run_service.main.Consumer") as mock:
        yield mock


@pytest.fixture
def mock_pubsub_publisher():
    with patch("cloude_run_service.main.publisher") as mock:
        yield mock


def test_consume_batch_invalid_country():
    """Test that an invalid country code returns a 400 error."""
    response = client.post("/consume/fr")
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid country code. Use 'us' or 'br'."


def test_consume_batch_no_messages(mock_kafka_consumer):
    """Test the endpoint behavior when Kafka returns no messages."""
    mock_cons_instance = mock_kafka_consumer.return_value
    mock_cons_instance.consume.return_value = []

    response = client.post("/consume/us")
    assert response.status_code == 200
    assert response.json()["message"] == "No new messages to consume."


def test_consume_batch_us_success(mock_kafka_consumer, mock_pubsub_publisher):
    """Test successful processing and validation of a US sales record."""
    mock_cons_instance = mock_kafka_consumer.return_value

    # Simulate a valid US Kafka message
    mock_msg = MagicMock()
    mock_msg.error.return_value = None
    mock_msg.value.return_value = b"""{
        "transaction_id": "123",
        "transaction_time": "2023-10-01T10:00:00Z",
        "store": "New York",
        "employee": "E001",
        "models_purchased": [{"line_num": 1, "model": "X", "model_price": 100.0}],
        "payment": {
            "card_information": {"card_number": "1111", "card_expires": "12/25"},
            "total": {"payment": 100.0, "currency": "USD"}
        }
    }"""
    mock_cons_instance.consume.return_value = [mock_msg]

    response = client.post("/consume/us?batch_size=1")

    assert response.status_code == 200
    assert response.json()["processed_count"] == 1
    assert mock_pubsub_publisher.publish.called


def test_consume_batch_validation_failure_dlt(
    mock_kafka_consumer, mock_pubsub_publisher
):
    """Test that invalid data is routed to the Dead Letter Topic (DLT)."""
    mock_cons_instance = mock_kafka_consumer.return_value

    # Simulate invalid JSON/Data
    mock_msg = MagicMock()
    mock_msg.error.return_value = None
    mock_msg.value.return_value = b'{"invalid": "data"}'
    mock_msg.offset.return_value = 500
    mock_cons_instance.consume.return_value = [mock_msg]

    response = client.post("/consume/us")

    assert response.status_code == 200
    assert response.json()["routed_to_dlt_count"] == 1
    # Check if publisher was called for the DLT path
    args, kwargs = mock_pubsub_publisher.publish.call_args
    assert "error_detail" in kwargs
