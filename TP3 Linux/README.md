# README

## I. Services systemd

### 1. Intro

Si on veut afficher le nombre de services systemd dispos sur la machine:

````
[vagrant@node1 ~]$ sudo systemctl list-unit-files -t service -a | grep service | wc -l
156
````

Si on veut afficher le nombre de services systemd actifs et en cours d'exécution ("running") sur la machine:

````
[vagrant@node1 ~]$ sudo systemctl -t service | grep service | grep running | wc -l
17
````

Si on veut afficher le nombre de services systemd qui ont échoué ("failed") ou qui sont inactifs ("exited") sur la machine:

````
[vagrant@node1 ~]$  sudo systemctl -t service -a | grep service | grep -E 'exited|failed' | wc -l
18
````

Si on veut afficher les services systemd qui démarrent automatiquement au boot ("enabled"):

````
sudo systemctl list-unit-files -t service | grep enabled
````

### 2. Analyse d'un service


On fait d'abord la commande :

````
[vagrant@node1 ~]$ sudo systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
````

On voit alors que le path de l'unité nginx.service est :
````
/usr/lib/systemd/system/nginx.service
````

Ensuite on fait :
````
[vagrant@node1 ~]$ systemctl cat nginx.service
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
````

On va donc voir en details ce que font les lignes :
```
-ExecStart
-ExecStartPre
-PIDFile
-Type
-ExecReload
-Description
-After
```
* Afficher son contenu et expliquer les lignes qui comportent :

    *   ``ExecStart:`` spécifie les commandes ou les scripts à réaliser lorsque l'unité est lancée

    *   ``ExecStartPre:`` spécifie des commandes personnalisées à exécuter avant ExecStart

    *   ``PIDFile:`` (PID: Identifiant de processus) spécifie un PID stable pour le processus principal du service

    *   ``Type:`` forking- le processus lancé par ExecStart engendre un processus enfant qui devient le processus principal du service. Le processus parent s'arrête lorsque le démarrage est terminé

    *   ``ExecReload:`` spécifie les commandes ou scripts à réaliser lorsque l'unité est rechargée.

    *   ``Description:`` description significative de l'unité. En tant qu'exemple, le texte est affiché dans la sortie de la commande systemctl status

    *   ``After:`` définit l'ordre dans lequel les unités sont lancées. L'unité est lancée uniquement après l'activation des unités spécifiées dans After


### 3. Création d'un service

#### A. Serveur web

Pour créer un service, on crée un fichier, le mien s'appelle :
````
http.service
````

On le remplit en mettant la configuration du service:
````
[Unit]
Description= Service WEB

[Service]
Type=simple
Environment="PORT=8080"
ExecStartPre=/bin/scriptweb/httppre.sh
RemainAfterExit=no
ExecStart=/usr/bin/python3 -m http.server ${PORT}
ExecStopPost=/bin/scriptweb/httpstop.sh

[Install]
WantedBy=multi-user.target
````

Pour ma part, j'ai associé deux scripts à ce fichier, un pour le ExecStartPre et un pour le ExecStopPost:
````
#!/bin/bash
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload
````

````
#!/bin/bash

firewall-cmd --remove-port=8080/tcp --permanent
firewall-cmd --reload
````

Ensuite on démarre le service :
````
[vagrant@node1 system]$ sudo systemctl daemon-reload
[vagrant@node1 system]$ sudo systemctl start http.service
````

On regarde si il est bien fonctionnel:

````
[vagrant@node1 scriptweb]$ sudo systemctl status http.service 
● http.service - Service WEB
   Loaded: loaded (/etc/systemd/system/http.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-10-07 13:42:45 UTC; 42min ago
 Main PID: 3323 (python3)
   CGroup: /system.slice/http.service
           └─3323 /usr/bin/python3 -m http.server 8080

Oct 07 13:42:45 node1.tp3.b2 systemd[1]: Started Service WEB.
````

````
[vagrant@node1 scriptweb]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: dhcpv6-client ssh
  ports: 8080/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
  ````

  Le port 8080 est bien ouvert.

  Ensuite on fait en sorte qu'il démarre à chaque démarrage de la machine:
  ````
  [vagrant@node1 scriptweb]$ sudo systemctl enable http.service
  ````

  On vérifie ensuite que le serveur web est bien fonctionnel:
  ````
  [vagrant@node1 scriptweb]$ curl 192.168.2.31:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="swapfile">swapfile</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="vagrant/">vagrant/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
````

#### B. Sauvegarde

On commence par créer un utilisateur pour la sauvegarde et on le configure :

````
[vagrant@node1 ~]$ sudo useradd backup
[vagrant@node1 ~]$ sudo passwd backup
[vagrant@node1 ~]$ sudo usermod -aG wheel backup
````

Ensuite on crée un fichier qui va être notre service:
````
sudo vim /etc/systemd/system/backup.service
````
````
[Unit]
Description=Sauvegarde

[Service]
Type=simple
#User=backup
RemainAfterExit=yes
PIDFILE=/var/run/backup.pid
ExecStartPre=/bin/scriptsave/backuppre.sh
ExecStart=/bin/scriptsave/backup.sh
ExecStartPost=/bin/scriptsave/backupstop.sh
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
````

J'ai mis la ligne du user en commentaires volontairement car j'ai eu des gros soucis en laissant cette ligne active.

On doit ensuite reload les services:

````
sudo systemctl daemon-reload
````

Ensuite on crée 3 scripts (qui seront à part sur le git):

````
[vagrant@node1 scriptsave]$ sudo touch backuppre.sh
[vagrant@node1 scriptsave]$ sudo touch backup.sh
[vagrant@node1 scriptsave]$ sudo touch backupstop.sh
````

Ensuite on doit configurer le timer pour que la backup se fasse toutes les heures:

````
[vagrant@node1 ~]$ sudo touch /usr/lib/systemd/system/backup.timer
````

````
[Unit]
Description=Backup toutes les heures

[Timer]
OnCalendar=*-*-* *:00:00
Unit=backup.service

[Install]
WantedBy=multi-user.target
````

On doit le lancer:

````
[vagrant@node1 system]$ sudo systemctl start backup.timer
[vagrant@node1 system]$ sudo systemctl status backup.timer
● backup.timer - Backup toutes les heures
   Loaded: loaded (/usr/lib/systemd/system/backup.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Fri 2020-10-09 13:07:37 UTC; 9min ago

Oct 09 13:07:37 node1.tp3.b2 systemd[1]: Started Backup toutes les heures.
````

On vérifie que le timer est fonctionnel:

````
[vagrant@node1 system]$ systemctl list-timers
NEXT                         LEFT       LAST                         PASSED       UNIT                         ACTIVATES
Fri 2020-10-09 14:00:00 UTC  37min left n/a                          n/a          backup.timer                 backup.service
Sat 2020-10-10 09:07:27 UTC  19h left   Fri 2020-10-09 08:04:04 UTC  5h 18min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

2 timers listed.
Pass --all to see loaded but inactive timers, too.
````


## II. Autres features

### 1. Gestion de boot

On commence par récupérer une diagramme du boot, au format SVG:

````
[vagrant@node1 ~]$ systemd-analyze plot > ekip.svg
````

* Ensuite, on veut analyser les 3 services les plus lents à démarrer:

  * http.service (17.812s)
  * vboxadd.service (30.865s)
  * firewalld.service (5.866s)

### 2. Gestion de l'heure

````
[vagrant@node1 ~]$ timedatectl
      Local time: Fri 2020-10-09 13:49:09 UTC
  Universal time: Fri 2020-10-09 13:49:09 UTC
        RTC time: Fri 2020-10-09 13:49:08
       Time zone: UTC (UTC, +0000)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
````
On regarde d'abord le fuseau horaire, c'est la ligne 'Time zone', on est donc sur le fuseau horaire UTC.

Ensuite on regarde si on est synchronisés avec un serveur NTP, c'est la ligne 'NTP synchronized', donc oui.

On veut changer notre fuseau horaire, on regarde d'abord les fuseaus horaires disponibles mais il y en a énormément, donc on fait:
````
[vagrant@node1 ~]$ timedatectl list-timezones | grep Paris
````

On le change donc:
````
[vagrant@node1 ~]$ sudo timedatectl set-timezone Europe/Paris
[vagrant@node1 ~]$ timedatectl
      Local time: Fri 2020-10-09 15:55:16 CEST
  Universal time: Fri 2020-10-09 13:55:16 UTC
        RTC time: Fri 2020-10-09 13:55:15
       Time zone: Europe/Paris (CEST, +0200)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  Sun 2020-03-29 01:59:59 CET
                  Sun 2020-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  Sun 2020-10-25 02:59:59 CEST
                  Sun 2020-10-25 02:00:00 CET
````

### 3. Gestion des noms et de la résolution de noms

````
[vagrant@node1 ~]$ hostnamectl
   Static hostname: node1.tp3.b2
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 3e2530c63fbfea42847fd90a96ed1431
           Boot ID: 7653d36a6eb9422c95cec17170f5fb1e
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64
````

On veut donc le changer:

````
[vagrant@node1 ~]$ sudo hostnamectl set-hostname ekip.tp3.b2
````

On vérifie:
````
[vagrant@node1 ~]$ hostnamectl
   Static hostname: ekip.tp3.b2
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 3e2530c63fbfea42847fd90a96ed1431
           Boot ID: 7653d36a6eb9422c95cec17170f5fb1e
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64
````


