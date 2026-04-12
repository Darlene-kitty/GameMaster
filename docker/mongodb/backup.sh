#!/bin/bash
# ============================================
# SCRIPT DE BACKUP AUTOMATISÉ - MONGODB → S3
# TPS Cloud, Virtualisation & Datacenter
# ============================================

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="rocketchat_backup_${TIMESTAMP}.archive.gz"
BACKUP_PATH="/tmp/${BACKUP_NAME}"

echo "========================================="
echo "🚀 BACKUP MONGODB VERS S3"
echo "========================================="
echo "Timestamp: ${TIMESTAMP}"
echo "Database: ${MONGO_DATABASE:-rocketchat}"
echo ""

# Vérification variables d'environnement
if [ -z "$MONGO_ROOT_USER" ] || [ -z "$MONGO_ROOT_PASS" ]; then
    echo "❌ ERREUR: Variables MongoDB non définies"
    exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$S3_BUCKET_NAME" ]; then
    echo "❌ ERREUR: Variables AWS S3 non définies"
    exit 1
fi

# Construction URI MongoDB
MONGO_URI="mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASS}@mongo:27017/${MONGO_DATABASE:-rocketchat}?authSource=admin"

echo "📦 Dump de la base de données..."
mongodump --uri="${MONGO_URI}" --archive="${BACKUP_PATH}" --gzip

if [ $? -eq 0 ]; then
    echo "✅ Dump réussi: ${BACKUP_PATH}"
    echo ""
    echo "☁️  Upload vers S3: s3://${S3_BUCKET_NAME}/rocketchat/daily/${BACKUP_NAME}"
    
    aws s3 cp "${BACKUP_PATH}" "s3://${S3_BUCKET_NAME}/rocketchat/daily/${BACKUP_NAME}" \
        --storage-class STANDARD_IA
    
    if [ $? -eq 0 ]; then
        echo "✅ Upload S3 réussi"
        
        # Nettoyer les vieux backups locaux (> 7 jours)
        find /tmp -name "rocketchat_backup_*.archive.gz" -mtime +7 -delete 2>/dev/null || true
        
        rm "${BACKUP_PATH}"
        echo "🧹 Nettoyage terminé"
    else
        echo "❌ Échec de l'upload S3"
        exit 1
    fi
else
    echo "❌ Échec du dump MongoDB"
    exit 1
fi

echo ""
echo "========================================="
echo "✅ BACKUP TERMINÉ AVEC SUCCÈS"
echo "=========================================" 
