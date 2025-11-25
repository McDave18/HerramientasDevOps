set -e

echo "Actualizacion de paquetes"
sudo apt-get update -y
#sudo apt-get upgrade -y

echo "Utilidades"
sudo apt-get install -y curl git

echo "Instalacion de Node.js y nginx"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y nginx

echo "Configuraciones y permisos"
sudo mkdir -p /var/www/nodeapp

# Detectar usuario apropiado (ubuntu en AWS, root en DO)
APP_USER="ubuntu"
if ! id "$APP_USER" >/dev/null 2>&1; then
  APP_USER="$(whoami)"
fi

sudo chown "$APP_USER:$APP_USER" /var/www/nodeapp
cd /var/www/nodeapp

# Ctrl c + v 
cat << 'EOF' > package.json
{
  "name": "node-nginx-example",
  "version": "1.0.0",
  "description": "Node.js + Nginx + Packer",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "author": "David Huerta - UNIR",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

cat << 'EOF' > server.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Validación de deploy de la AMI e instancia desde AWS');
});

app.listen(port, () => {
  console.log(`Escuchando en http://localhost:${port}`);
});
EOF

npm install

echo "Creando servicio systemd para la app Node.js..."
sudo tee /etc/systemd/system/nodeapp.service > /dev/null << 'EOF'
[Unit]
Description=Node.js App plus Nginx
After=network.target

#Variables de configuracion
[Service]
Environment=PORT=3000
Type=simple
User=www-data
WorkingDirectory=/var/www/nodeapp
ExecStart=/usr/bin/node server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nodeapp

echo "Configuracion de reverse proxy"
sudo tee /etc/nginx/sites-available/nodeapp > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/nodeapp /etc/nginx/sites-enabled/nodeapp
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl enable nodeapp

echo "App NodeJS corriendo por puerto 80"
