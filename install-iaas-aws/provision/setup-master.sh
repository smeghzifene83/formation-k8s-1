#!/bin/bash

export PUBLIC_IP=63.32.144.131

echo $PUBLIC_IP

##

# 
echo "setup-master hostname=$(hostname) ip=$(hostname -i)"

# $(hostname -i) return 127.0.0.1 192.169.32.20, so IP must be hard coded
# add --pod-network-cidr=10.244.0.0/16 for flannel (or Canal)
echo "(2/4) init the cluster"
sudo kubeadm config images pull
sudo kubeadm init --apiserver-cert-extra-sans=$PUBLIC_IP --pod-network-cidr=10.244.0.0/16


# allow current user to use kubectl
echo "add kube config in $HOME/.kube"
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# auto completion
echo "source <(kubectl completion bash)" >> ~/.bashrc

echo "(3/4) Installing a pod network : $POD_NETWORK"

kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/canal.yaml


# prepare add node https://kubernetes.io/fr/docs/setup/independent/create-cluster-kubeadm/#join-nodes
echo "kubeadm token list :"
kubeadm token list

 # discovery-token-ca-cert-hash
echo "discovery-token-ca-cert-hash :"

openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
