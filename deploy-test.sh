#!/bin/bash

AWS_REGION="us-east-1"
ACCOUNT_ID="852843827150"
REPO_NAME="test"
CONTAINER_NAME="test-container"
PORT=3000

echo "🔑 Authentification à Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "🛑 Arrêt du conteneur existant : $CONTAINER_NAME"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

echo "🧹 Suppression des anciennes images inutilisées..."
docker image prune -f

echo "⬇️  Récupération de la dernière image..."
docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest

echo "🚀 Lancement du nouveau conteneur..."
docker run -d --name $CONTAINER_NAME -p 80:$PORT $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest

echo "✅ Déploiement terminé ! 🎉"