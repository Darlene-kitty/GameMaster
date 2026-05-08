"""
Service de statut CI/CD - TPS Rocket.Chat
Sert de probe de santé pour le pipeline GitHub Actions
et expose un endpoint de statut pour le monitoring.
"""
from flask import Flask, jsonify
from typing import Tuple
import os

app = Flask(__name__)

# Variables d'environnement requises pour le readiness probe
REQUIRED_ENV_VARS: Tuple[str, ...] = ("MONGO_ROOT_USER", "ADMIN_PASS")

SERVICE_NAME = "rocket-chat-tps"


@app.route("/")
def index():
    """Endpoint racine — informations générales sur le service."""
    return jsonify({
        "service": SERVICE_NAME,
        "status": "running",
        "description": "CI/CD health probe for Rocket.Chat TPS deployment",
    }), 200


@app.route("/health")
def health():
    """Liveness probe — indique que le processus est vivant."""
    return jsonify({"status": "healthy"}), 200


@app.route("/ready")
def ready():
    """Readiness probe — vérifie les variables d'environnement critiques."""
    missing = [v for v in REQUIRED_ENV_VARS if not os.getenv(v)]
    if missing:
        return jsonify({"status": "not ready", "missing": missing}), 503
    return jsonify({"status": "ready"}), 200


if __name__ == "__main__":
    # Pour développement local uniquement
    app.run(host="0.0.0.0", port=5000, debug=False)
