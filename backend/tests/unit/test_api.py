import pytest


pytestmark = pytest.mark.unit


def test_health_returns_ok(client):
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_profile_has_name_and_role(client):
    response = client.get("/api/profile")
    assert response.status_code == 200
    assert response.json()["name"]
    assert "Ingeniería" in response.json()["role"]


def test_contact_rejects_invalid_email(client):
    response = client.post(
        "/api/contact",
        json={"name": "Wendy", "email": "no-es-correo", "message": "Hola, este es un mensaje"},
    )
    assert response.status_code == 422
