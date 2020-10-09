#!/bin/bash

backup="/srv/site1"

name=site1

# Destination du fichier de sauvegarde
destination="/save/site1"

# On compresse le fichier
tar -czf ${name}$(date '+%Y%m%d_%H%M').tar.gz --absolute-names ${backup}/index.html

# On déplace le fichier
mv ${name}$(date '+%Y%m%d_%H%M').tar.gz ${destination}