#!/bin/sh

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1 nfs nfs
192.168.1.41 gitea gitea
192.168.1.42 mariadb maria
192.168.1.43 nginx nginx" > /etc/hosts

yum install -y nfs-utils

systemctl start nfs-server rpcbind
systemctl enable nfs-server rpcbind

mkdir gitea
chmod 777 ./gitea
mkdir mariadb
chmod 777 ./mariadb
mkdir nginx
chmod 777 ./nginx


echo "/home/vagrant/gitea 192.168.1.41(rw,sync,no_root_squash)
/home/vagrant/mariadb 192.168.1.42(rw,sync,no_root_squash)
/home/vagrant/nginx 192.168.1.43(rw,sync,no_root_squash)" > /etc/exports

firewall-cmd --permanent --add-service mountd
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --permanent --add-service nfs
firewall-cmd --reload
chmod 777 ./gitea