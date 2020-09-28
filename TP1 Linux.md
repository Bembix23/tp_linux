# TP1 : Déploiement classique

## 0. Prérequis

Déjà la premiere étape était de se connecter en SSH à notre machine via powershell. Ensuite nous pouvons commencer les prérequis de ce TP.

Tout d'abord nous faisons la commande "lsblk" afin de voir les disques sur notre machine:

```
[user@localhost ~]$ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0    8G  0 disk 
├─sda1            8:1    0    1G  0 part /boot     
└─sda2            8:2    0    7G  0 part 
  ├─centos-root 253:0    0  6.2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]    
sdb               8:16   0    5G  0 disk 
sr0              11:0    1 1024M  0 rom  
sr1              11:1    1 1024M  0 rom  
```

On voit donc le disque que je viens de créer, "sdb" qui a un stockage de 5Go.
Nous allons ajouter ce disque en tant que "Physical Volume":

```
[user@localhost ~]$ sudo pvcreate /dev/sdb
[sudo] password for user: 
  Physical volume "/dev/sdb" successfully created.
  ```


```
[user@localhost ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <7.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              1791
  Free PE               0
  Allocated PE          1791
  PV UUID               UJdeqd-dqMO-Khj4-shoX-0GTL-7jm3-UmKnUh

  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               deZJ6R-8EE2-v6Wp-jC8Z-Gsu8-2muU-kCH97s
  ```

  Je crée ensuite un "Volume Group":

  ````
  [user@localhost ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
  ````

  ````
  [user@localhost ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <7.00 GiB
  PE Size               4.00 MiB
  Total PE              1791
  Alloc PE / Size       1791 / <7.00 GiB
  Free  PE / Size       0 / 0
  VG UUID               ZisgbY-78Gu-j2cU-cBDa-qUD1-wa1U-U1WUcc

  --- Volume group ---
  VG Name               data
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <5.00 GiB
  PE Size               4.00 MiB
  Total PE              1279
  Alloc PE / Size       0 / 0
  Free  PE / Size       1279 / <5.00 GiB
  VG UUID               3POOKR-0Gz6-9hTX-8WLs-mJpq-NvoP-l9Ie0j
  ````


  Nous allons ensuite créer des "Logical Volumes", ce sont mes partitions, la premiere doit être de 2Go, et la seconde de 3Go (ce qu'il reste):

  ````
  [user@localhost ~]$ sudo lvcreate -L 2G data -n data1
  Logical volume "data1" created.
[user@localhost ~]$ sudo lvcreate -l 100%FREE data -n data2
  Logical volume "data2" created.
  ````


  ````
  [user@localhost ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/centos/swap
  LV Name                swap
  VG Name                centos
  LV UUID                hNkLWF-2LuW-bzaV-KHoG-6aRk-eHby-4WwOM7
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-01-30 12:01:08 +0100
  LV Status              available
  # open                 2
  LV Size                820.00 MiB
  Current LE             205
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/centos/root
  LV Name                root
  VG Name                centos
  LV UUID                iywbff-sVCC-VF3B-QtpD-AeVL-dHLM-FcFTbJ
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-01-30 12:01:09 +0100
  LV Status              available
  # open                 1
  LV Size                <6.20 GiB
  Current LE             1586
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/data/data1
  LV Name                data1
  VG Name                data
  LV UUID                evKUbH-3jSF-y5w1-bENP-dv3Y-p4mV-QlTKSh
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2020-09-23 16:47:32 +0200
  LV Status              available
  # open                 0
  LV Size                2.00 GiB
  Current LE             512
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/data/data2
  LV Name                data2
  VG Name                data
  LV UUID                IOenBp-OIAW-cFc3-BGAA-ehSF-vzvV-NDU11K
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2020-09-23 16:47:53 +0200
  LV Status              available
  # open                 0
  LV Size                <3.00 GiB
  Current LE             767
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:3
  ````

  Je viens alors de créer mes partitions, je vais maintenant les formater puis ensuite les monter: d'abord on les formate:


  ````
  [user@localhost ~]$ sudo !!
sudo mkfs -t ext4 /dev/data/data1
[sudo] password for user: 
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
````


Il faut ensuite qu'on les monte:


````
[user@localhost ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 484M     0  484M   0% /dev
tmpfs                    496M     0  496M   0% /dev/shm
tmpfs                    496M  6.8M  489M   2% /run
tmpfs                    496M     0  496M   0% /sys/fs/cgroup
/dev/mapper/centos-root  6.2G  1.3G  5.0G  21% /
/dev/sda1               1014M  136M  879M  14% /boot
tmpfs                    100M     0  100M   0% /run/user/1000
/dev/mapper/data-data1   2.0G  6.0M  1.8G   1% /mnt/data1
````

Pour finir nous voulons que les partitions soient montées automatiquement au démarrage, il faut alors configurer cela dans le fichier "fstab":

````
[user@localhost ~]$ sudo cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Jan 30 12:01:09 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=775417a1-cb59-44ec-8c11-80595017e9b6 /boot                   xfs     defaults        0 0       
/dev/mapper/centos-swap swap                    swap    defaults        0 0

/dev/data/data1 /mnt/data1 ext4 defaults 0 0
````

Pour vérifier si cette opération fonctionne comme il faut, on "unmount" la partition avec la commande "umount". Ensuite nous pouvons vérifier si la même partition est toujours montée (car nous l'avons configuré de tel sorte à ce qu'elle le soit automatiquement) avec la commande  "mount -av":

````
[user@localhost ~]$ sudo umount /mnt/data1/
[user@localhost ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
swap                     : ignored
mount: /mnt/data1 does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/data1               : successfully mounted
````

Je refais ensuite les manipulations de formatages et de montages pour la deuxieme partition.



On vérifie que j'ai Internet avec la commande "curl":

````
[user@node1 ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
````


Ensuite on veut que nos deux machines puissent se joindre avec un ping: on fait alors un ping avec l'ip de l'autre machine:

````
[user@node1 ~]$ ping 192.168.1.13
PING 192.168.1.13 (192.168.1.13) 56(84) bytes of data.
64 bytes from 192.168.1.13: icmp_seq=1 ttl=64 time=0.491 ms
64 bytes from 192.168.1.13: icmp_seq=2 ttl=64 time=0.221 ms
64 bytes from 192.168.1.13: icmp_seq=3 ttl=64 time=1.17 ms
64 bytes from 192.168.1.13: icmp_seq=4 ttl=64 time=1.32 ms
64 bytes from 192.168.1.13: icmp_seq=5 ttl=64 time=1.01 ms
64 bytes from 192.168.1.13: icmp_seq=6 ttl=64 time=1.17 ms
64 bytes from 192.168.1.13: icmp_seq=7 ttl=64 time=0.798 ms
64 bytes from 192.168.1.13: icmp_seq=8 ttl=64 time=1.13 ms
64 bytes from 192.168.1.13: icmp_seq=9 ttl=64 time=0.556 ms
^C
--- 192.168.1.13 ping statistics ---
9 packets transmitted, 9 received, 0% packet loss, time 8014ms
rtt min/avg/max/mdev = 0.221/0.877/1.324/0.359 ms
````

````
[user@node2 ~]$ ping 192.168.1.12
PING 192.168.1.12 (192.168.1.12) 56(84) bytes of data.
64 bytes from 192.168.1.12: icmp_seq=1 ttl=64 time=0.313 ms
64 bytes from 192.168.1.12: icmp_seq=2 ttl=64 time=0.415 ms
64 bytes from 192.168.1.12: icmp_seq=3 ttl=64 time=0.405 ms
64 bytes from 192.168.1.12: icmp_seq=4 ttl=64 time=0.489 ms
64 bytes from 192.168.1.12: icmp_seq=5 ttl=64 time=0.491 ms
64 bytes from 192.168.1.12: icmp_seq=6 ttl=64 time=0.563 ms
64 bytes from 192.168.1.12: icmp_seq=7 ttl=64 time=0.612 ms
^C
--- 192.168.1.12 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6009ms
rtt min/avg/max/mdev = 0.313/0.469/0.612/0.097 ms
````


Sur les commandes précedentes on voit que nos machines ont un nom, qui est respectivement :
-node1.tp1.b2
-node2.tp1.b2

On veut ensuite que nos deux machines se joignent seulement avec leur nom. On doit alors configurer le fichier "/etc/hosts" :


````
[user@node1 ~]$ sudo cat /etc/hosts
[sudo] password for user: 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.13    node2.tp1.b2
````

On voit que nous avons ajouté une ligne, comprenant l'IP de l'autre machine ainsi que skon nom associé, et ceci pour les deux machines. Cela nous permet alors d'associer l'IP au nom. On teste ensuite cela avec un ping:

````
[user@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (192.168.1.13) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.1.13): icmp_seq=1 ttl=64 time=0.294 ms
64 bytes from node2.tp1.b2 (192.168.1.13): icmp_seq=2 ttl=64 time=1.10 ms
64 bytes from node2.tp1.b2 (192.168.1.13): icmp_seq=3 ttl=64 time=0.469 ms
^C
--- node2.tp1.b2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.294/0.622/1.105/0.349 ms
````

````
[user@node2 ~]$ ping node1.tp1.b2
PING node1.tp1.b2 (192.168.1.12) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=0.353 ms
64 bytes from node1.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=0.841 ms
64 bytes from node1.tp1.b2 (192.168.1.12): icmp_seq=3 ttl=64 time=1.35 ms
^C
--- node1.tp1.b2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.353/0.849/1.355/0.410 ms
````

Le pare-feu a été configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires:

````
[user@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client ssh
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
  ````



  ## 1. Setup serveur Web

  
Il faut tout d'abord que l'on crée deux fichiers intitulés "index.html" sur node1.tp1.b2. Le premier fichier index.html doit être situé dans le dossier /srv/site1 , le deuxième doit être dans le dossier /srv/site2:

````
[user@node1 ~]$ cd /srv/site1
[user@node1 site1]$ touch index.html
touch: cannot touch ‘index.html’: Permission denied
[user@node1 site1]$ sudo !!
sudo touch index.html
[sudo] password for user: 
[user@node1 site1]$ ls
index.html  lost+found
[user@node1 site1]$ cd 
[user@node1 ~]$ cd /srv/site2
[user@node1 site2]$ sudo touch index.html
[user@node1 site2]$ ls
index.html  lost+found
````

Ensuite je dois changer les permissions du fichier, son utilisateur propriétaire et son groupe propriétaire, pour cela j'utilise deux commandes : "chmod" pour changer les droits du fichier et "chown" pour changer les propriétaires:

````
[user@node1 site2]$ sudo chmod 400 /srv/site1/index.html
[sudo] password for user: 
[user@node1 site2]$ ls -al /srv/site1
total 20
drwxr-xr-x. 3 root root  4096 Sep 28 14:00 .    
drwxr-xr-x. 4 root root    32 Sep 24 17:10 ..   
-r--------. 1 root root     0 Sep 28 14:00 index.html
drwx------. 2 root root 16384 Sep 24 17:09 lost+found
````
Ici je viens de modifier les droits du fichier "index.html", sur sa ligne, nous voyons que l'utilisateur propriétaire (pour l'instant root) a seulement les droits de lire le fichier(r--), tous les autres utilisateurs n'ont aucun droit. La configuration de ces droits s'est faites directement avec le code 400 dans la commande "chmod".

Maintenant je vais modifier l'utilisateur propriétaire et le groupe propriétaire, cela se fait avec la commande chown:

````
[user@node1 site2]$ sudo chown web:web /srv/site1/index.html
[user@node1 site2]$ ls -al /srv/site1
total 20
drwxr-xr-x. 3 root root  4096 Sep 28 14:00 .
drwxr-xr-x. 4 root root    32 Sep 24 17:10 ..
-r--------. 1 web web    0 Sep 28 14:00 index.html
drwx------. 2 root root 16384 Sep 24 17:09 lost+found
````

Ici on voit sur la ligne de "index.html" que l'utilisateur et le groupe ont changé ( précédement root et root), maintenant ce sont web et web.

Ensuite on ouvre les ports pour HTTP et HTTPS:
````
[user@node1 ~]$ sudo firewall-cmd --zone=public 
--add-service=http
success
[user@node1 ~]$ sudo firewall-cmd --zone=public 
--add-service=https
success
````

J'ai ajouté au préalable du contenu aux deux fichiers "index.html".

Il faut ensuite obligatoirement générer un certificat afin de pouvoir utiliser HTTPS:
 ````
 [user@node1 ~]$ openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
Generating a 2048 bit RSA private key
.......+++
......................+++
writing new private key to 'server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a 
Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,  
If you enter '.', the field will be left blank. 
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:        
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:      
Common Name (eg, your name or your server's hostname) []:node1.tp1.b2
Email Address []:
````



Il faut ensuite modifier le fichier de configuration /etc/nginx/nginx.conf :

````
[user@node1 ~]$ sudo cat /etc/nginx/nginx.conf
[sudo] password for user: 
worker_processes 1;
error_log /var/log/nginx/error.log;
user web;


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
                alias /srv/site1;
        }

        location /site2 {
                alias /srv/site2;
        }
    }
    server {
        listen 443 ssl;

        server_name node1.tp1.b2;
        ssl_certificate /etc/pki/tls/certs/server.crt;
        ssl_certificate_key /etc/pki/tls/private/server.key;

        location / {
            return 301 /site1;
        }

        location /site1 {
            alias /srv/site1;
        }
        location /site2 {
            alias /srv/site2;
        }
    }
}
````

J'essaie ensuite d'avoir accès aux sites à partir de node2.tp1.b2, d'abord HTTP:

````
[user@node2 ~]$ curl -L node1.tp1.b2/site1
Premier site    
[user@node2 ~]$ curl -L node1.tp1.b2/site2
Deuxieme site 
````

Puis en HTTPS:

````
[user@node2 ~]$ curl -kL https://node1.tp1.b2/site1
Premier site    
[user@node2 ~]$ curl -kL https://node1.tp1.b2/site2
Deuxieme site   
````

On voit donc que la deuxieme machine a bien accès aux sites.

## 2. Script de sauvegarde

On commence d'abord par créer le script:
````
user@node1 ~]$ touch tp1_backup.sh
````

On crée ensuite le dossier principal de la sauvegarde nommé "backup" :
````
[user@node1 ~]$ mkdir backup 
````

Puis ensuite les sous-dossiers "site1" et "site2":

````
[user@node1 ~]$ mkdir backup/site1
[user@node1 ~]$ mkdir backup/site2
````

Ensuite je fais le script, le voici:

````
[user@node1 backup]$ sudo cat tp1_backup.sh 
#!/bin/bash
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
````

Ensuite on installe crontabs, ici je l'avais déjà sur ma machine.

On le start:
````
sudo systemctl start crond.service
````

Ensuite il faut le configurer, on fait donc la commande : crontab -e 
Il faut y mettre :
````
0 * * * * backup tp1.backup.sh /srv/site1                                   0 * * * * backup tp1.backup.sh /srv/site2
````

## III. Monitoring, alerting

Tout d'abord on install Netdata :
````
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
````

![](https://i.imgur.com/1dLDnCz.png)

On modifie le fichier /etc/netdata/edit-config health_alarm_notify.conf , on crée une ligne DISCORD_WEBHOOK_URL="", le lien de notre WebHook. Ca donne :
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/760231766828122142/i6rX3_FBQWH-NdNa2zpVnvOLhh4oe1ZovbkvZQwiEXjclYocPOrJWfa1Ag8LwqvpJp3-"

On modifie enuite le fichier de configuration de NGINX:

````
[user@node1 backup]$ sudo cat /etc/nginx/nginx.conf
worker_processes 1;
error_log /var/log/nginx/error.log;
user web;


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
                alias /srv/site1;
        }

        location /site2 {
                alias /srv/site2;
        }
    }
    server {
        listen 443 ssl;

        server_name node1.tp1.b2;
        ssl_certificate /etc/pki/tls/certs/server.crt;
        ssl_certificate_key /etc/pki/tls/private/server.key;

        location / {
            return 301 /site1;
        }

        location /site1 {
            alias /srv/site1;
        }
        location /site2 {
            alias /srv/site2;
        }
        location ~ /netdata/(?<ndpath>.*) {
            proxy_redirect off;
            proxy_set_header Host $host;

            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection "keep-alive";
            proxy_store off;
            proxy_pass http://netdata/$ndpath$is_args$args;

            gzip on;
            gzip_proxied any;
            gzip_types *;
        }
    }
}
````






