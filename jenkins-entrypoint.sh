#!/bin/bash

# Ouvre les permissions du socket Docker pour que Jenkins puisse l'utiliser
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock
    echo ">>> Permissions du socket Docker corrigées"
fi

# Lance Jenkins (tini gère les signaux proprement)
exec /usr/bin/tini -- /usr/local/bin/jenkins.sh
