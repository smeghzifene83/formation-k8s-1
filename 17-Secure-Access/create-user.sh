#!/bin/bash

USAGE="USAGE : ./create-user.sh <USER_NAME> <USER_GROUP>"

USER_NAME=$1
USER_GROUP=$2


if [ -z "$1" ]
  then
    echo "USER_NAME not supplied"
    echo $USAGE
    exit 1
fi

if [ -z "$2" ]
  then
    echo "USER_GROUP not supplied"
    echo $USAGE
    exit 1
fi

# BEFORE calling script

CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[].name}')
CLUSTER_SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[].cluster.server}')
kubectl config view --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > certificate-authority.crt

echo "--------------------------------------------------------------------------------"
echo "create config for USER:$USER_NAME member of $USER_GROUP on cluster $CLUSTER_NAME"
echo "--------------------------------------------------------------------------------"


# delete previous
rm -f $USER_NAME* 
kubectl delete certificatesigningrequests.certificates.k8s.io  $USER_NAME-csr

# create key
openssl genrsa -out $USER_NAME.key 2048

# create csr : Certificate Signing Request 
openssl req -new -key $USER_NAME.key -out $USER_NAME.csr -subj "/CN=$USER_NAME/O=$USER_GROUP"

# create csr : Certificate Signing Request
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $USER_NAME-csr
spec:
  groups:
  - system:authenticated
  request: $(cat $USER_NAME.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
  - client auth
EOF

# approve
kubectl certificate approve $USER_NAME-csr

# download cert
kubectl get csr $USER_NAME-csr -o jsonpath='{.status.certificate}' \
    | base64 --decode > $USER_NAME.crt

#-----------------------------------------------------------

# set cluster
kubectl config --kubeconfig=$USER_NAME.config set-cluster $CLUSTER_NAME --server=$CLUSTER_SERVER_URL --certificate-authority=certificate-authority.crt --embed-certs

# set-credentials
kubectl config --kubeconfig=$USER_NAME.config set-credentials $USER_NAME --client-certificate=$USER_NAME.crt --client-key=$USER_NAME.key --embed-certs=true

# set-contex
kubectl config --kubeconfig=$USER_NAME.config set-context $USER_NAME@$CLUSTER_NAME --cluster=$CLUSTER_NAME --user=$USER_NAME --namespace=$USER_NAME-default

# set-default context
kubectl config --kubeconfig=$USER_NAME.config use-context $USER_NAME@$CLUSTER_NAME

#-----------------------------------------------------------

# use a clusterrolebinding to bind view role on all namespaces for all the members of "dev" group
kubectl create clusterrolebinding $USER_GROUP-view-all-ns --clusterrole=view --group=$USER_GROUP

# create user ns
kubectl create ns $USER_NAME-default
kubectl create ns $USER_NAME-ns1
kubectl create ns $USER_NAME-ns2

# label user ns
kubectl label namespace $USER_NAME-default formation=true
kubectl label namespace $USER_NAME-ns1 formation=true
kubectl label namespace $USER_NAME-ns2 formation=true

# use a rolebinding to bind admin role on user namespaces for the $USER_NAME 
kubectl create rolebinding $USER_NAME-admin --clusterrole=admin --user=$USER_NAME -n $USER_NAME-default
kubectl create rolebinding $USER_NAME-admin --clusterrole=admin --user=$USER_NAME -n $USER_NAME-ns1
kubectl create rolebinding $USER_NAME-admin --clusterrole=admin --user=$USER_NAME -n $USER_NAME-ns2