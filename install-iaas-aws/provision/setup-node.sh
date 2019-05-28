#!/bin/bash
echo "setup-node hostname=$(hostname) ip=$(hostname -i)"
export MASTER_PUBLIC_IP=63.32.144.131

export MY_TOKEN=rcperr.1yqx2bzedn2cmljo

export MY_CA_CERT_HASH=c7488c49341929544ea2a0ec998627488c5287d91dd51d938b621b3777ec6106

# join the cluster
echo "$(hostname) join the cluster"
sudo kubeadm join --token $MY_TOKEN $MASTER_PUBLIC_IP:6443 --discovery-token-ca-cert-hash=sha256:$MY_CA_CERT_HASH


