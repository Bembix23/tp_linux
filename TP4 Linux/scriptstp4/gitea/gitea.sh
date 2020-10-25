#!/bin/sh

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1 gitea gitea
192.168.1.42 mariadb maria
192.168.1.43 nginx nginx
192.168.1.44 nfs nfs" > /etc/hosts

yum install -y wget
yum install -y git

firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload

wget -O gitea https://dl.gitea.io/gitea/1.12.5/gitea-1.12.5-linux-amd64
chmod +x gitea

adduser git
passwd -f -u git

mkdir -p /var/lib/gitea
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea

echo "[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
###
# Don't forget to add the database service requirements
###
#
#Requires=mysql.service
#Requires=mariadb.service
#Requires=postgresql.service
#Requires=memcached.service
#Requires=redis.service
#
###
# If using socket activation for main http/s
###
#
#After=gitea.main.socket
#Requires=gitea.main.socket
#
###
# (You can also provide gitea an http fallback and/or ssh socket too)
#
# An example of /etc/systemd/system/gitea.main.socket
###
##
## [Unit]
## Description=Gitea Web Socket
## PartOf=gitea.service
##
## [Socket]
## Service=gitea.service
## ListenStream=<some_port>
## NoDelay=true
##
## [Install]
## WantedBy=sockets.target
##
###
[Service]
# Modify these two values and uncomment them if you have
# repos with lots of files and get an HTTP error 500 because
# of that
###
#LimitMEMLOCK=infinity
#LimitNOFILE=65535
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
# If using Unix socket: tells systemd to create the /run/gitea folder, which will contain the gitea.sock file
# (manually creating /run/gitea doesn't work, because it would not persist across reboots)
#RuntimeDirectory=gitea
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
# If you want to bind Gitea to a port below 1024, uncomment
# the two values below, or use socket activation to pass Gitea its ports as above
###
#CapabilityBoundingSet=CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_BIND_SERVICE
###
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/gitea.service

systemctl daemon-reload
systemctl enable gitea
systemctl start gitea

yum install -y nfs-utils
mkdir /mnt/gitea
mount 192.168.1.44:/home/vagrant/gitea /mnt/gitea

echo "#!/bin/sh
tar -czf backup.tar.gz /etc/gitea/
cp ./backup.tar.gz /mnt/gitea" > /mnt/gitea/backup.sh

echo "0 * * * * /mnt/gitea/backup.sh" > /var/spool/cron/vagrant