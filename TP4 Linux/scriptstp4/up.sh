#!/bin/sh

yum update -y
#Désolé je préfère nano xd
yum install -y nano

setenforce 0
echo "SELINUX=permissive\nSELINUXTYPE=targeted" > /etc/selinux/config

systemctl start firewalld
systemctl enable firewalld
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --reload