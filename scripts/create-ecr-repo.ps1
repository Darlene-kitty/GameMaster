# Script PowerShell pour créer le repository ECR
# Usage: .\scripts\create-ecr-repo.ps1

$ErrorActionPreference = "Stop"

$REGION = "eu-west-1"
$REPO_NAME = "rocket-chat-tps"

Write-Host "🚀 Création du repository ECR: $REPO_NAME dans la région $REGION" -ForegroundColor Green

try {
    # Créer le repository
    aws ecr create-repository `
      --repository-name $REPO_NAME `
      --region $REGION `
      --image-scanning-configuration scanOnPush=true `
      --encryption-configuration encryptionType=AES256

    Write-Host "✅ Repository ECR créé avec succès!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Informations:" -ForegroundColor Cyan
    
    aws ecr describe-repositories `
      --repository-names $REPO_NAME `
      --region $REGION `
      --query 'repositories[0].[repositoryName,repositoryUri,createdAt]' `
      --output table

    Write-Host ""
    Write-Host "🔐 Repository URI:" -ForegroundColor Cyan
    $accountId = aws sts get-caller-identity --query Account --output text
    Write-Host "$accountId.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME" -ForegroundColor Yellow

} catch {
    Write-Host "❌ Erreur lors de la création du repository:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
