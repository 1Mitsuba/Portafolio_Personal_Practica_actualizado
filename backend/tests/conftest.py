import os

import psycopg
import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def postgres_database():
    database_url = os.getenv("TEST_DATABASE_URL")
    if not database_url:
        pytest.skip("Define TEST_DATABASE_URL para ejecutar las pruebas de integración.")

    with psycopg.connect(database_url, autocommit=True) as connection:
        connection.execute(
            "CREATE TABLE IF NOT EXISTS contact_messages ("
            "id BIGSERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, "
            "email VARCHAR(254) NOT NULL, message TEXT NOT NULL, "
            "created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())"
        )
        connection.execute("TRUNCATE contact_messages RESTART IDENTITY")
    yield database_url
    with psycopg.connect(database_url, autocommit=True) as connection:
        connection.execute("TRUNCATE contact_messages RESTART IDENTITY")
