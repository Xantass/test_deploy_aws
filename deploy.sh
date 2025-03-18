#!/bin/bash

AWS_REGION="us-east-1"
ACCOUNT_ID="852843827150"
REPO_NAME_FRONTEND="ugram-frontend"
REPO_NAME_BACKEND="ugram-backend"
CONTAINER_NAME_FRONTEND="ugram-container-frontend"
CONTAINER_NAME_BACKEND="ugram-container-backend"
PORT_FRONTEND=3000
PORT_BACKEND=8080

echo "🔑 Authentification à Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

if [ "$(docker ps -q -f name=$CONTAINER_NAME_FRONTEND)" ]; then
    echo "🛑 Arrêt du conteneur frontend existant : $CONTAINER_NAME_FRONTEND"
    docker stop $CONTAINER_NAME_FRONTEND
    docker rm $CONTAINER_NAME_FRONTEND
fi

if [ "$(docker ps -q -f name=$CONTAINER_NAME_BACKEND)" ]; then
    echo "🛑 Arrêt du conteneur backend existant : $CONTAINER_NAME_BACKEND"
    docker stop $CONTAINER_NAME_BACKEND
    docker rm $CONTAINER_NAME_BACKEND
fi

echo "🧹 Suppression des anciennes images inutilisées..."
docker image prune -f

echo "⬇️  Récupération de la dernière image frontend..."
docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME_FRONTEND:latest

echo "⬇️  Récupération de la dernière image backend..."
docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME_BACKEND:latest

echo "🚀 Lancement du nouveau conteneur frontend..."
docker run -d --name $CONTAINER_NAME -p 80:$PORT_FRONTEND --network network-ugram $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME_FRONTEND:latest

echo "🚀 Lancement du nouveau conteneur backend..."
docker run -d --name $CONTAINER_NAME -p 81:$PORT_BACKEND --network network-ugram $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME_BACKEND:latest

echo "✅ Déploiement terminé ! 🎉"