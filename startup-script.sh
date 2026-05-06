#!/bin/bash

# actualizar sistema
apt update -y

# instalar docker
apt install -y docker.io git
systemctl start docker
systemctl enable docker

# instalar docker compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# crear usuario de trabajo
useradd -m n8nuser
usermod -aG docker n8nuser

# ir al home
cd /home/n8nuser

# clonar repo base (tendrás que crearlo)
git clone https://github.com/IfcAddict/taller-n8n.git
cd taller-n8n

# obtener IP pública
PUBLIC_IP=$(curl -s ifconfig.me)

# generar .env dinámico
cat <<EOF > .env
DOMAIN=${PUBLIC_IP}.nip.io
N8N_HOST=${PUBLIC_IP}.nip.io
N8N_PROTOCOL=https
WEBHOOK_URL=https://${PUBLIC_IP}.nip.io/
EOF

# levantar contenedores
docker-compose up -d

# permisos
chown -R n8nuser:n8nuser /home/n8nuser
