#!/bin/bash
set -euo pipefail

# Redirect output for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

ENV_TYPE="${environment}"
IMAGE_TAG="prod"

if [ "$ENV_TYPE" == "development" ]; then
  IMAGE_TAG="dev"
fi

IMAGE_NAME="tohidazure/strapi-app:$IMAGE_TAG"

echo "[INFO] Starting setup at $(date)"
echo "[INFO] Environment: $ENV_TYPE, Image: $IMAGE_NAME"

# 1. Setup Docker using official script
echo "[INFO] Installing Docker..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for other software managers to finish..."
    sleep 5
done

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

systemctl enable --now docker
usermod -aG docker ubuntu

# 2. Setup Application Containers
echo "[INFO] Setting up Strapi with Postgres..."

docker network create strapi-net || true

# Run Postgres Container
docker run -d --name postgres --network strapi-net \
  --restart unless-stopped \
  -e POSTGRES_DB=strapi \
  -e POSTGRES_USER=strapi \
  -e POSTGRES_PASSWORD=strapi \
  -v strapi_db_data:/var/lib/postgresql/data \
  postgres:15

# Pull Image
docker pull "$IMAGE_NAME"

# Run Strapi Container
docker run -d --name strapi --network strapi-net \
  --restart unless-stopped \
  -e HOST=0.0.0.0 \
  -e PORT=1337 \
  -e APP_KEYS="L80oF5QgNgop5eVHAfv/YQ==,z2W4EytW0t26Y60SosSq0w==,Lct7m1y05yvHMvYz4kHA3w==,PwhDt/t6xpgV0R4ijtqw+g==" \
  -e API_TOKEN_SALT="wXFSdVSmHyT4a9029gmZOg==" \
  -e ADMIN_JWT_SECRET="lCZ6Il5zxYO+mCDJcD5T6g==" \
  -e TRANSFER_TOKEN_SALT="bdQMTtZ7X3KZek7R4NQ5DA==" \
  -e ENCRYPTION_KEY="rprKZLq/4TEplTNjMIhvpA==" \
  -e JWT_SECRET="KIWx1Bt/s82RZDfuUl8qjA==" \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=postgres \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=strapi \
  -e DATABASE_USERNAME=strapi \
  -e DATABASE_PASSWORD=strapi \
  -e NODE_ENV="$ENV_TYPE" \
  -p 1337:1337 \
  "$IMAGE_NAME"

echo "[INFO] Setup complete. Docker ps output:"
docker ps

echo "[INFO] Setup complete. Docker ps output:"
docker ps
