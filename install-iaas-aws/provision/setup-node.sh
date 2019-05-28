#!/bin/sh
echo "setup-node hostname=$(hostname) ip=$(hostname -i)"
export MASTER_PUBLIC_IP=52.47.81.140

export MY_TOKEN=zx5fx1.16bntqexmica7wyb

export MY_CA_CERT_HASH=580f958bbc7967a237452e48b66c8f15c50e6c512a26ba3ab6ebcf061322517c

# join the cluster
echo "$(hostname) join the cluster"
sudo kubeadm join --token $MY_TOKEN $MASTER_PUBLIC_IP:6443 --discovery-token-ca-cert-hash=sha256:$MY_CA_CERT_HASH


