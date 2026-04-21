import json
import logging
from fastapi import FastAPI, HTTPException
from confluent_kafka import Consumer, KafkaException
from google.cloud import pubsub_v1

from cloude_run_service.config import config
from cloude_run_service.schema import USSalesTransaction, BRSalesElement

logging.basicConfig(level=logging.INFO)

app = FastAPI(title="Kafka to PubSub Batch Consumer")
# Initialize Pub/Sub Publisher
publisher = pubsub_v1.PublisherClient()


@app.post("/consume/{country}")
def consume_batch(country: str, batch_size: int = 100, timeout: float = 15.0):
    if country.lower() not in ["us", "br"]:
        raise HTTPException(
            status_code=400, detail="Invalid country code. Use 'us' or 'br'."
        )

    # Determine the Pub/Sub topics based on the country
    if country.lower() == "us":
        target_pubsub_topic = config.PUBSUB_TOPIC_US
        target_dlt_topic = config.PUBSUB_DLT_US
    else:
        target_pubsub_topic = config.PUBSUB_TOPIC_BR
        target_dlt_topic = config.PUBSUB_DLT_BR

    topic_path = publisher.topic_path(config.PROJECT_ID, target_pubsub_topic)
    dlt_path = publisher.topic_path(config.PROJECT_ID, target_dlt_topic)

    topic_name = f"mk-{country.lower()}-sales-topic"
    group_id = f"sales-consumer-{country.lower()}"

    logging.info(f"Connecting to Kafka topic: {topic_name} with group: {group_id}")
    consumer = Consumer(config.get_kafka_config(group_id))
    consumer.subscribe([topic_name])

    processed_count = 0
    dlt_count = 0

    try:
        messages = consumer.consume(num_messages=batch_size, timeout=timeout)
        logging.info(f"Received {len(messages)} messages from Kafka")
        if not messages:
            return {
                "status": "success",
                "message": "No new messages to consume.",
                "count": 0,
                "dlt_count": 0,
            }

        for msg in messages:
            if msg.error():
                logging.error(f"Kafka error: {msg.error()}")
                continue

            # Get raw bytes
            raw_bytes = msg.value()
            try:
                # Decoding and validating
                raw_data = json.loads(raw_bytes.decode("utf-8"))

                if country.lower() == "us":
                    validated_data = USSalesTransaction(**raw_data).model_dump()
                    pubsub_payload = json.dumps(validated_data).encode("utf-8")
                    future = publisher.publish(
                        topic_path, data=pubsub_payload, country=country.upper()
                    )
                    future.result()
                    processed_count += 1
                elif country.lower() == "br":
                    validated_data = [
                        BRSalesElement(**item).model_dump() for item in raw_data
                    ]
                    for item in validated_data:
                        pubsub_payload = json.dumps(item).encode("utf-8")
                        future = publisher.publish(
                            topic_path, data=pubsub_payload, country=country.upper()
                        )
                        future.result()
                    processed_count += 1

            except Exception as e:
                # Publish to the DLT
                error_message = str(e)
                logging.warning(
                    f"Validation failed for message offset {msg.offset()}: {error_message}. Routing to DLT."
                )

                future = publisher.publish(
                    dlt_path,
                    data=raw_bytes,
                    country=country.upper(),
                    error_detail=error_message,
                    original_offset=str(msg.offset()),
                )
                future.result()
                dlt_count += 1

    except KafkaException as e:
        logging.error(f"Kafka Exception: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        consumer.close()

    return {
        "status": "success",
        "message": f"Successfully processed batch for {country.upper()}",
        "processed_count": processed_count,
        "routed_to_dlt_count": dlt_count,
    }
