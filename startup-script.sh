#!/bin/bash

# Añadir claves GPG de docker
apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Añadir repositorio de docker
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# actualizar sistema
apt update -y

# instalar docker
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# obtener IP pública
PUBLIC_IP=$(curl -s ifconfig.me)

# generar .env dinámico
cat <<EOF > .env
DOMAIN=${PUBLIC_IP}.nip.io
N8N_HOST=${PUBLIC_IP}.nip.io
N8N_PROTOCOL=https
WEBHOOK_URL=https://${PUBLIC_IP}.nip.io/
EOF

# generar archivo caddy
cat <<EOF > Caddyfile
${PUBLIC_IP}.nip.io {
    reverse_proxy n8n:5678
}
EOF

# levantar contenedores
docker compose up -d
