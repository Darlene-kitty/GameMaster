#!/bin/bash

# Configuration des chemins locaux
CERTS_DIR="./docker/nginx/certs"

echo "================================================="
echo " Génération des Certificats SSL Locaux Auto-Signés"
echo "================================================="

# Créer le répertoire de destination s'il n'existe pas
mkdir -p "$CERTS_DIR"

# Lancer un conteneur alpine jetable pour générer les certificats via OpenSSL sans toucher au système hôte
docker run --rm -v "$(pwd)/$CERTS_DIR:/certs" alpine/openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /certs/localhost.key \
    -out /certs/localhost.crt \
    -subj "/C=FR/ST=Local/L=Local/O=TPS/OU=Development/CN=localhost"

echo "✅ Certificats générés avec succès dans : $CERTS_DIR"
echo " Fichiers créés : "
echo " - localhost.crt (Certificat Public)"
echo " - localhost.key (Clé Privée)"
echo "================================================="
