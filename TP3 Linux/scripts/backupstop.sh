#!/bin/bash

backup="/srv/site1"

# Destination du fichier de sauvegarde
destination="/save/site1"

# Si il y a + de 7 fichier dans le dossier
if [[ $(ls -Al ${destination} | wc -l) > 7 ]]
then
    rm ${destination}/$(ls -tr1 ${destination} | grep -m 1 "")
fi