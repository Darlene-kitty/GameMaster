"""
Tests unitaires pour l'application Flask (health probe CI/CD).
"""
import sys
import os

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import app, REQUIRED_ENV_VARS, SERVICE_NAME  # noqa: E402


# ─── Fixtures ─────────────────────────────────────────────────────────────────


@pytest.fixture
def client():
    """Client de test Flask avec mode TESTING activé."""
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


# ─── /health ──────────────────────────────────────────────────────────────────


class TestHealthEndpoint:
    """Liveness probe : doit toujours répondre 200 avec status=healthy."""

    def test_returns_200_with_healthy_status(self, client):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.get_json() == {"status": "healthy"}

    def test_returns_json_content_type(self, client):
        response = client.get("/health")
        assert "application/json" in response.content_type


# ─── / ────────────────────────────────────────────────────────────────────────


class TestRootEndpoint:
    """Endpoint racine : informations générales sur le service."""

    def test_returns_200(self, client):
        assert client.get("/").status_code == 200

    def test_payload_contains_service_name_and_status(self, client):
        data = client.get("/").get_json()
        assert data["service"] == SERVICE_NAME
        assert data["status"] == "running"
        assert "description" in data


# ─── /ready ───────────────────────────────────────────────────────────────────


class TestReadyEndpoint:
    """Readiness probe : dépend des variables d'environnement critiques."""

    def test_returns_200_when_all_env_vars_set(self, client, monkeypatch):
        for var in REQUIRED_ENV_VARS:
            monkeypatch.setenv(var, "dummy_value")
        assert client.get("/ready").status_code == 200

    def test_returns_503_when_all_env_vars_missing(self, client, monkeypatch):
        for var in REQUIRED_ENV_VARS:
            monkeypatch.delenv(var, raising=False)
        response = client.get("/ready")
        assert response.status_code == 503
        data = response.get_json()
        assert "missing" in data
        assert set(data["missing"]) == set(REQUIRED_ENV_VARS)

    def test_returns_503_when_one_env_var_missing(self, client, monkeypatch):
        """Vérifie qu'une seule variable manquante suffit à bloquer le readiness."""
        first_var, *rest = REQUIRED_ENV_VARS
        monkeypatch.delenv(first_var, raising=False)
        for var in rest:
            monkeypatch.setenv(var, "dummy_value")
        response = client.get("/ready")
        assert response.status_code == 503
        assert first_var in response.get_json()["missing"]

    def test_missing_list_only_contains_absent_vars(self, client, monkeypatch):
        """La liste 'missing' ne doit pas inclure les variables présentes."""
        first_var, *rest = REQUIRED_ENV_VARS
        monkeypatch.delenv(first_var, raising=False)
        for var in rest:
            monkeypatch.setenv(var, "dummy_value")
        data = client.get("/ready").get_json()
        for var in rest:
            assert var not in data["missing"]


# ─── Erreurs HTTP ─────────────────────────────────────────────────────────────


class TestHttpErrors:
    """Comportement standard sur les routes et méthodes invalides."""

    def test_404_on_unknown_route(self, client):
        assert client.get("/route-inexistante").status_code == 404

    def test_405_on_wrong_method(self, client):
        assert client.post("/").status_code == 405


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
