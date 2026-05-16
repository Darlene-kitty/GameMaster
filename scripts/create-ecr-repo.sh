#!/bin/bash

# Script pour créer le repository ECR
# Usage: bash scripts/create-ecr-repo.sh

set -e

REGION="eu-west-1"
REPO_NAME="rocket-chat-tps"

echo "🚀 Création du repository ECR: $REPO_NAME dans la région $REGION"

# Créer le repository
aws ecr create-repository \
  --repository-name "$REPO_NAME" \
  --region "$REGION" \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256

echo "✅ Repository ECR créé avec succès!"
echo ""
echo "📋 Informations:"
aws ecr describe-repositories \
  --repository-names "$REPO_NAME" \
  --region "$REGION" \
  --query 'repositories[0].[repositoryName,repositoryUri,createdAt]' \
  --output table

echo ""
echo "🔐 Pour vous connecter à ECR:"
echo "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$REGION.amazonaws.com"
