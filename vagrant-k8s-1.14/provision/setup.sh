#!/bin/sh
echo "setup hostname=$(hostname) ip=$(hostname -i)"

sudo -i

# Specify a the K8s major version to install (x.y or x.y.z) the latest fix version will be installed
export K8S_MAJOR_VERSION=1.14

# Docker major version to install (x.y)
export DOKER_MAJOR_VERSION=18.09

#extend /etc/hosts
cat /vagrant/provision/etc_hosts_extend >> /etc/hosts

#update
apt-get update > /dev/null

#Disable swap to avoid  fatal errors occurred:unning with swap on is not supported. Please disable swap
swapoff -a
sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Docker

echo "Installing Docker on hostname=$(hostname) ip=$(hostname -i)"

# https://kubernetes.io/docs/setup/independent/install-kubeadm/ 
# ne pas changer le cgroupdriver car celui utilisé par Docker ET celui de kubectl sont deja TOUS LES DEUX cgroupfs


apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

apt-get install -y bash-completion

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

apt-get update
# install supported version of Docker : 18.09
DOCKER_EXACT_VERSION=$(apt-cache madison docker-ce | grep $DOKER_MAJOR_VERSION | head -1 | awk '{print $3}') 

apt-get install -y docker-ce=$DOCKER_EXACT_VERSION docker-ce-cli=$DOCKER_EXACT_VERSION containerd.io


# https://kubernetes.io/docs/setup/cri/
# Setup daemon. Cgroup Driver: systemd
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker


# le groupe docker est initialise lors de l'install de docker-ce
usermod -aG docker vagrant

# for flannel driver see https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network
sysctl net.bridge.bridge-nf-call-iptables=1

echo "(1/4) Installing kubeadm on hostname=$(hostname) ip=$(hostname -i)"
# kubeadm, kubelet and kubectl
# apt-transport-https allready installed for docker-ce
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

K8S_EXACT_VERSION=$(apt-cache madison kubectl | grep $K8S_MAJOR_VERSION | head -1 | awk '{print $3}')

apt-get install -y kubelet=$K8S_EXACT_VERSION kubeadm=$K8S_EXACT_VERSION kubectl=$K8S_EXACT_VERSION

# cri-tools ebtables ethtool kubeadm kubectl kubelet kubernetes-cni socat
