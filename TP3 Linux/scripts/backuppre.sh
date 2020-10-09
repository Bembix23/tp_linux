#!/bin/bash

backup='/srv/site1'

# destination du fichier de sauvegarde
destination='/save/site1'

if [ ! -d ${backup} ]
then
    echo "No folder ${backup}"
        exit 1
fi

# Si dossier vide
if [ ! -e ${backup}/index.html ]
then
    echo "No index.html"
    exit 1
fi

if [ ! -d ${destination} ]
then
    mkdir ${destination}
fi