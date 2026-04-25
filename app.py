"""
Service de statut CI/CD - TPS Rocket.Chat
Sert de probe de santé pour le pipeline GitHub Actions
et expose un endpoint de statut pour le monitoring.
"""
from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify({
        "service": "rocket-chat-tps",
        "status": "running",
        "description": "CI/CD health probe for Rocket.Chat TPS deployment",
    }), 200


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/ready")
def ready():
    """Readiness probe — vérifie les variables d'environnement critiques."""
    missing = [v for v in ("MONGO_ROOT_USER", "ADMIN_PASS") if not os.getenv(v)]
    if missing:
        return jsonify({"status": "not ready", "missing": missing}), 503
    return jsonify({"status": "ready"}), 200


if __name__ == "__main__":
    # Pour développement local uniquement
    app.run(host="0.0.0.0", port=5000, debug=False)
