#!/bin/sh


# Constante
CANAL_POD_NETWORK=Canal
# Constante
FLANNEL_POD_NETWORK=Flannel
# Choose your POD_NETWORK Canal ou Flannel
POD_NETWORK=$CANAL_POD_NETWORK

export PUBLIC_IP=52.47.81.140
export PUBLIC_DNS=ec2-52-47-81-140.eu-west-3.compute.amazonaws.com

echo $PUBLIC_IP,$PUBLIC_DNS
##

# 
echo "setup-master hostname=$(hostname) ip=$(hostname -i)"

# $(hostname -i) return 127.0.0.1 192.169.32.20, so IP must be hard coded
# add --pod-network-cidr=10.244.0.0/16 for flannel (or Canal)
echo "(2/4) init the cluster"
kubeadm config images pull
sudo kubeadm init --apiserver-cert-extra-sans=$PUBLIC_IP,$PUBLIC_DNS --pod-network-cidr=10.244.0.0/16


# allow current user to use kubectl
echo "add kube config in $HOME/.kube"
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# auto completion
echo "source <(kubectl completion bash)" >> ~/.bashrc

echo "(3/4) Installing a pod network : $POD_NETWORK"

if [ $POD_NETWORK = $FLANNEL_POD_NETWORK ]; then
    # https://stackoverflow.com/questions/47845739/configuring-flannel-to-use-a-non-default-interface-in-kubernetes
    kubectl apply -f /vagrant/provision/kube-flannel.yml
fi

if [ $POD_NETWORK = $CANAL_POD_NETWORK ]; then
    kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
    kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/canal.yaml
fi


# prepare add node https://kubernetes.io/fr/docs/setup/independent/create-cluster-kubeadm/#join-nodes

kubeadm token list

    # discovery-token-ca-cert-hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'





# deploiement du dashboard
echo "deploiement du dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml





# init du repertoire generated-conf
mkdir -p /vagrant/generated-conf
# copie du fichier admin.conf pour permettre la connection au cluster depuis la machine hote
sudo cp /etc/kubernetes/admin.conf /vagrant/generated-conf

echo "gestion acces du dashboard"
# creation du user admin pour le dashbord
kubectl create -f /vagrant/provision/admin-user.yaml
sleep 5
# attribution du role admin
kubectl create -f /vagrant/provision/clusterRoleBinding.yaml
# force pause to fix Error from server (NotFound): secrets "admin-user" not found
sleep 10
# affichage du token
kubectl -n kube-system describe secret admin-user
# copie du token pour utilisation ulterieur
kubectl -n kube-system describe secret admin-user > /vagrant/generated-conf/admin-user-token.txt
