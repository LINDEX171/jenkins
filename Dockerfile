# On part de l'image Jenkins officielle avec JDK 17
FROM jenkins/jenkins:lts-jdk17

# On passe en root pour pouvoir installer des paquets
USER root

# On installe Docker CLI (pour que Jenkins puisse lancer des conteneurs)
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# On ajoute l'utilisateur jenkins au groupe docker
RUN groupadd -f docker && usermod -aG docker jenkins

# Copie le script de démarrage qui corrige les permissions du socket Docker
COPY jenkins-entrypoint.sh /usr/local/bin/jenkins-entrypoint.sh
RUN chmod +x /usr/local/bin/jenkins-entrypoint.sh

# L'entrypoint tourne en root pour pouvoir corriger les permissions du socket Docker
# Jenkins.sh gère ensuite le démarrage du processus Jenkins
ENTRYPOINT ["/usr/local/bin/jenkins-entrypoint.sh"]

# Jenkins écoute sur le port 8080
