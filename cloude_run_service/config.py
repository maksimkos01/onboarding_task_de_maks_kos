import os
from google.cloud import secretmanager


class Config:
    PROJECT_ID = os.environ.get("PROJECT_ID", "syntio-onboarding-prod")

    # Pub/Sub topics
    PUBSUB_TOPIC_US = os.environ.get("PUBSUB_TOPIC_US", "mk-us-sales-topic")
    PUBSUB_TOPIC_BR = os.environ.get("PUBSUB_TOPIC_BR", "mk-br-sales-topic")
    # Dead Letter Topics
    PUBSUB_DLT_US = os.environ.get("PUBSUB_DLT_US", "mk-us-sales-dlt")
    PUBSUB_DLT_BR = os.environ.get("PUBSUB_DLT_BR", "mk-br-sales-dlt")

    KAFKA_BOOTSTRAP_SERVERS = os.environ.get(
        "KAFKA_BOOTSTRAP_SERVERS", "35.205.51.194:9096"
    )
    KAFKA_USERNAME_SECRET_NAME = "mk-user-secret"
    KAFKA_PASSWORD_SECRET_NAME = "mk-user-password"

    @staticmethod
    def get_secret(secret_id: str, version_id: str = "latest") -> str:
        client = secretmanager.SecretManagerServiceClient()
        name = f"projects/{Config.PROJECT_ID}/secrets/{secret_id}/versions/{version_id}"
        response = client.access_secret_version(request={"name": name})
        return response.payload.data.decode("UTF-8")

    def get_kafka_config(self, group_id: str) -> dict:
        """Returns the configuration dictionary for a Kafka Consumer."""
        return {
            "bootstrap.servers": self.KAFKA_BOOTSTRAP_SERVERS,
            "security.protocol": "SASL_SSL",
            "ssl.ca.location": "ca.crt",
            "sasl.mechanism": "SCRAM-SHA-512",
            "sasl.username": self.get_secret(self.KAFKA_USERNAME_SECRET_NAME),
            "sasl.password": self.get_secret(self.KAFKA_PASSWORD_SECRET_NAME),
            "group.id": group_id,
            "auto.offset.reset": "earliest",
        }


config = Config()
