#!/bin/sh

# ==========================================================
# SCRIPT DE SAUVEGARDE MONGODB VERS AWS S3 (CRON WORKER)
# ==========================================================

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/tmp/mongodump-$DATE"
ZIP_FILE="/tmp/rocketchat-backup-$DATE.zip"

echo "[$DATE] Début de la sauvegarde MongoDB..."

# 1. Extraction des données (mongodump)
# Utilise les variables d'environnement du docker-compose
mongodump --uri="${MONGO_URL}" --out="$BACKUP_DIR"

if [ $? -eq 0 ]; then
  echo "[$DATE] Mongodump réussi."
else
  echo "[$DATE] ERREUR : Échec du mongodump."
  exit 1
fi

# 2. Compression
cd /tmp
zip -r "$ZIP_FILE" "mongodump-$DATE"

# 3. Envoi vers AWS S3
echo "[$DATE] Upload vers S3 (${S3_BUCKET_NAME}) en cours..."
aws s3 cp "$ZIP_FILE" "s3://${S3_BUCKET_NAME}/backups/rocketchat-backup-$DATE.zip"

if [ $? -eq 0 ]; then
  echo "[$DATE] ✅ Sauvegarde envoyée sur S3 avec succès."
else
  echo "[$DATE] ❌ ERREUR lors de l'envoi sur S3."
  # Keep exit bad code so Docker compose can log it
  exit 2
fi

# Nettoyage
rm -rf "$BACKUP_DIR"
rm -f "$ZIP_FILE"

echo "[$DATE] Terminée."
