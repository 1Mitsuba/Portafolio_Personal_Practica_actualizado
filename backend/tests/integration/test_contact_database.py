import psycopg
import pytest


pytestmark = pytest.mark.integration


def test_contact_is_persisted(client, postgres_database, monkeypatch):
    monkeypatch.setenv("DATABASE_URL", postgres_database)
    response = client.post(
        "/api/contact",
        json={"name": "Wendy Ramírez", "email": "wendy@example.com", "message": "Quisiera conocer más sobre tus proyectos."},
    )
    assert response.status_code == 201
    with psycopg.connect(postgres_database) as connection:
        row = connection.execute("SELECT name, email FROM contact_messages").fetchone()
    assert row == ("Wendy Ramírez", "wendy@example.com")


def test_contact_trims_surrounding_whitespace(client, postgres_database, monkeypatch):
    monkeypatch.setenv("DATABASE_URL", postgres_database)
    response = client.post(
        "/api/contact",
        json={"name": "  Wendy  ", "email": "wendy@example.com", "message": "  Hola, deseo conversar sobre un proyecto.  "},
    )
    assert response.status_code == 201
    with psycopg.connect(postgres_database) as connection:
        row = connection.execute("SELECT name, message FROM contact_messages").fetchone()
    assert row == ("Wendy", "Hola, deseo conversar sobre un proyecto.")


def test_multiple_contacts_are_saved_as_separate_rows(client, postgres_database, monkeypatch):
    monkeypatch.setenv("DATABASE_URL", postgres_database)
    for name in ("Primera persona", "Segunda persona"):
        response = client.post(
            "/api/contact",
            json={"name": name, "email": "persona@example.com", "message": "Hola, deseo conversar sobre un proyecto."},
        )
        assert response.status_code == 201
    with psycopg.connect(postgres_database) as connection:
        count = connection.execute("SELECT COUNT(*) FROM contact_messages").fetchone()[0]
    assert count == 2
