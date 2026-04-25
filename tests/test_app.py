"""
Tests unitaires pour l'application Flask
"""
import pytest
import sys
import os

# Ajouter le répertoire parent au path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app


@pytest.fixture
def client():
    """Fixture pour le client de test Flask"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


class TestHealthEndpoint:
    """Tests pour l'endpoint /health"""
    
    def test_health_endpoint_exists(self, client):
        """Test que l'endpoint /health existe"""
        response = client.get('/health')
        assert response.status_code == 200
    
    def test_health_endpoint_returns_json(self, client):
        """Test que /health retourne du JSON"""
        response = client.get('/health')
        assert response.content_type == 'application/json'
    
    def test_health_endpoint_returns_healthy_status(self, client):
        """Test que /health retourne status=healthy"""
        response = client.get('/health')
        data = response.get_json()
        assert data['status'] == 'healthy'
    
    def test_health_endpoint_returns_200(self, client):
        """Test que /health retourne un code 200"""
        response = client.get('/health')
        assert response.status_code == 200


class TestRootEndpoint:
    """Tests pour l'endpoint racine /"""
    
    def test_root_endpoint_exists(self, client):
        """Test que l'endpoint / existe"""
        response = client.get('/')
        assert response.status_code == 200
    
    def test_root_endpoint_returns_json(self, client):
        """Test que / retourne du JSON"""
        response = client.get('/')
        assert response.content_type == 'application/json'
    
    def test_root_endpoint_contains_service_name(self, client):
        """Test que / contient le nom du service"""
        response = client.get('/')
        data = response.get_json()
        assert data['service'] == 'rocket-chat-tps'
        assert data['status'] == 'running'


class TestReadyEndpoint:
    """Tests pour l'endpoint /ready"""

    def test_ready_returns_200_when_env_set(self, client, monkeypatch):
        """Test que /ready retourne 200 quand les variables sont définies"""
        monkeypatch.setenv('MONGO_ROOT_USER', 'admin')
        monkeypatch.setenv('ADMIN_PASS', 'secret')
        response = client.get('/ready')
        assert response.status_code == 200

    def test_ready_returns_503_when_env_missing(self, client, monkeypatch):
        """Test que /ready retourne 503 quand les variables manquent"""
        monkeypatch.delenv('MONGO_ROOT_USER', raising=False)
        monkeypatch.delenv('ADMIN_PASS', raising=False)
        response = client.get('/ready')
        assert response.status_code == 503
        data = response.get_json()
        assert 'missing' in data


class TestAppConfiguration:
    """Tests pour la configuration de l'application"""
    
    def test_app_exists(self):
        """Test que l'application Flask existe"""
        assert app is not None
    
    def test_app_is_flask_instance(self):
        """Test que app est une instance Flask"""
        from flask import Flask
        assert isinstance(app, Flask)
    
    def test_testing_mode_can_be_enabled(self):
        """Test que le mode testing peut être activé"""
        app.config['TESTING'] = True
        assert app.config['TESTING'] is True


class TestErrorHandling:
    """Tests pour la gestion des erreurs"""
    
    def test_404_on_nonexistent_route(self, client):
        """Test qu'une route inexistante retourne 404"""
        response = client.get('/route-qui-nexiste-pas')
        assert response.status_code == 404
    
    def test_405_on_wrong_method(self, client):
        """Test qu'une mauvaise méthode HTTP retourne 405"""
        response = client.post('/')
        assert response.status_code == 405


class TestSecurityHeaders:
    """Tests pour les headers de sécurité (à implémenter)"""
    
    def test_no_server_header_leak(self, client):
        """Test qu'on ne leak pas d'info serveur (optionnel)"""
        response = client.get('/')
        # Vérifier qu'on n'expose pas trop d'infos
        assert 'Server' not in response.headers or 'Werkzeug' not in response.headers.get('Server', '')


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
