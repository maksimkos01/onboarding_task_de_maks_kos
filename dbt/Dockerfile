# Use a slim Python image
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=True
ENV DBT_PROFILES_DIR=/usr/app

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/app

COPY . .

RUN pip install --no-cache-dir --upgrade pip setuptools \
    && pip install --no-cache-dir dbt-bigquery certifi


ENTRYPOINT ["dbt", "build"]
