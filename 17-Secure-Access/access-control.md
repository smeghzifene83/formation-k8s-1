# Create a user "dev1" and Get Cert from K8s API

## create key

```sh
openssl genrsa -out dev1.key 2048
```

## create csr : Certificate Signing Request

https://kubernetes.io/docs/reference/access-authn-authz/authentication/#x509-client-certs

```sh
openssl req -new -key dev1.key -out dev1.csr -subj "/CN=dev1/O=dev"
```

## create csr object via K8s API

https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificate-signing-request-object-to-send-to-the-kubernetes-api

add usage "client auth"

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: dev1-csr
spec:
  groups:
  - system:authenticated
  request: $(cat dev1.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
  - client auth
EOF
```

```sh
kubectl get csr
NAME       AGE   REQUESTOR          CONDITION
dev1-csr   33s   kubernetes-admin   Pending
```

## approving

```
kubectl certificate approve dev1-csr
certificatesigningrequest.certificates.k8s.io/dev1-csr approved

kubectl get csr
NAME       AGE     REQUESTOR          CONDITION
dev1-csr   4m14s   kubernetes-admin   Approved,Issued
```

## download cert

```sh
kubectl get csr dev1-csr -o jsonpath='{.status.certificate}' \
    | base64 --decode > dev1.crt
```

## declare user

https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts

```sh
# check cluster name
kubectl config get-clusters

# set env var
CLUSTER_NAME=kubernetes
USER_NAME=dev1

# set-credentials
kubectl config set-credentials $USER_NAME --client-certificate=$USER_NAME.crt --client-key=$USER_NAME.key --embed-certs=true

# set-contex
kubectl config set-context $USER_NAME@$CLUSTER_NAME --cluster=$CLUSTER_NAME --user=$USER_NAME --namespace=dev-default

# list contexts
kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
         dev1@kubernetes               kubernetes   dev1               dev-default
*        kubernetes-admin@kubernetes   kubernetes   kubernetes-admin
```

## add binding to default cluster role

The group name "dev" match "O=dev" in subj ```openssl req -new -key dev1.key -out dev1.csr -subj "/CN=dev1/O=dev"```

```sh
# create the namespace
kubectl create ns dev-default

# use a rolebinding to bind admin role on dev1 namespace for all the members of "dev" group
kubectl create rolebinding dev-admin-dev-default-ns --clusterrole=admin --group=dev -n dev-default

# use a clusterrolebinding to bind view role on all namespaces for all the members of "dev" group
kubectl create clusterrolebinding dev-view-all-ns --clusterrole=view --group=dev
```

## check

```sh
config use-context dev1@kubernetes
Switched to context "dev1@kubernetes".

# get all on current namespace (dev1)
kubectl get all

# get all on all namespaces (OK)
kubectl get all --all-namespaces

# create deployment in current namespace (dev1)
kubectl create deployment nginx --image=nginx

# try to create deployment in default namespace
kubectl create deployment nginx --image=nginx -n default
> Error from server (Forbidden): deployments.apps is forbidden: User "dev1" cannot create resource "deployments" in API group "apps" in the namespace "default"

# swith to admin context
kubectl config use-context kubernetes-admin@kubernetes
```
