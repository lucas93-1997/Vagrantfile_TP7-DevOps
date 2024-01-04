#!/bin/bash

# Añadir el usuario 'jenkins' al grupo 'docker' 
sudo usermod -a -G docker jenkins 
sudo usermod -aG docker ${USER}


# Instalar Java
echo "Installing default-java"
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

# Instalar Jenkins
echo "Installing Jenkins"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
 https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
sudo echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \ 
 https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
 /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sleep 1m

# Imprimir la contraseña inicial de Jenkins
echo "Password Jenkins"
JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo $JENKINSPWD

# Instalar Docker
echo "Installing docker"
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Install Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Install Maven
sudo apt install maven -y

# Install Microk8s
sudo apt-get install snapd -y
sudo snap install microk8s --classic
sudo usermod -a -G microk8s vagrant
sudo chown -R vagrant ~/.kube

# Install Argocd
#sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
#sudo chmod +x /usr/local/bin/argocd
sudo microk8s kubectl create namespace argocd
sudo microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo brew install argocd
sudo microk8s kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
sudo microk8s kubectl port-forward svc/argocd-server -n argocd 8081:443
sudo microk8s argocd admin initial-password -n argocd
# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
helm version



sudo reboot






 
