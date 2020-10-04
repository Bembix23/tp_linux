#!/bin/bash
#Jules Dupuis
#30/09/2020

#Ajout association nom et IP de la machine
echo "192.168.2.21   node1.tp2.b2" >> /etc/hosts

#Ajout de l'utilisateur "user"
useradd user--
usermod -aG wheel user

#Ajout de l'utilisateur "web"
useradd web -M -s /sbin/nologin

#Modification des droits sur les certificats
chmod 400 /etc/pki/tls/private/server.key
chown web:web /etc/pki/tls/private/server.key
chmod 444 /etc/pki/tls/certs/server.crt
chown web:web /etc/pki/tls/certs/server.crt

#Ajout des services HTTP et HTTPS
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https

#Configuration de NGINX
echo "worker_processes 1;
error_log nginx_error.log;
events {
    worker_connections 1024;
}
http {
     server {
       listen 80;
        server_name node1.tp1.b2;
        location / {
                return 301 /site1;
        }
        location /site1 {
                alias /mnt/site1;
        }
        location /site2 {
                alias /mnt/site2;
        }
}
server {
        listen 443 ssl;
        server_name node1.tp2.b2;
        ssl_certificate server.crt;
        ssl_certificate_key server.key;
        location / {
            return 301 /site1;
        }
        location /site1 {
            alias /mnt/site1;
        }
        location /site2 {
            alias /mnt/site2;
        }
        location ~ /netdata/(?<ndpath>.*) {
            proxy_redirect off;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Host \$host;
            proxy_set_header X-Forwarded-Server \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection 'keep-alive';
            proxy_store off;
            proxy_pass http://netdata/\$ndpath\$is_args\$args;
            gzip on;
            gzip_proxied any;
            gzip_types *;
        }
    }
}" > /etc/nginx/nginx.conf

# Création des dossiers avec les sites HTML
mkdir /mnt/site1/
touch /mnt/site1/index.html
chown web:web /mnt/site1/index.html
chmod 550 /mnt/site1
chmod 440 /mnt/site1/index.html
echo '<h1>Site 1</h1>' | tee /mnt/site1/index.html


mkdir /mnt/site2/
touch /mnt/site2/index.html
chown web:web /mnt/site2/index.html
chmod 550 /mnt/site2
chmod 440 /mnt/site2/index.html
echo '<h1>Site 2</h1>' | tee /mnt/site2/index.html

#Génération du certificat
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=node1.tp2.b2"

mv server.crt /etc/nginx
mv server.key /etc/nginx

systemctl start nginx

#Création de l'utilisateur "backup"
useradd backup
usermod backup -aG web

#Creation des dossiers de la sauvegarde
mkdir backup
mkdir backup/site1
mkdir backup/site2
touch tp2.script.sh | mv tp2.script.sh backup/

#Script de backup
echo '#!/bin/bash
#Jules Dupuis
#28/09/2020

# Quoi sauvegarder
backup_files="$(basename $1)"

# Où
dest="./site/"

# Creation nom archive
day=$(date +%d-%m-%Y_%H%M%S)
hostname=${backup_files}
archive_file="${dest}-${day}.tar.gz"

#Message début
echo "Début de la sauvegarde de ${backup_files} vers ${dest}"
date
echo

#Sauvegarde
tar -czf "${archive_file}" "${dest}"

#Message fin
echo
echo "Sauvegarde terminée"
date

exit 0
' > tp2.script.sh

chmod +x tp2.script.sh

#Installation crontabs
sudo yum install crontabs

sudo systemctl start crond.service

#Installation Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait

sudo firewall-cmd --add-port=19999/tcp --permanent

sudo firewall-cmd --reload