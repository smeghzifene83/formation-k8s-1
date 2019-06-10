
# NETWORK POLICY

## TP1

https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/


### Create an nginx deployment

```sh
kubectl run nginx --image=nginx --replicas=2
kubectl expose deployment nginx --port=80
kubectl get svc,pod
```

### test access from another pod

```sh
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1 /bin/sh


# Waiting for pod default/busybox-472357175-y0m47 to be running, status is Pending, pod ready: false
# Hit enter for command prompt

wget --spider --timeout=1 nginx

```

### limit access

```yaml
vim nginx-policy.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: access-nginx
spec:
  podSelector:
    matchLabels:
      run: nginx
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: "true"
```

```sh
kubectl apply -f nginx-policy.yaml
```

### test access without access label

```sh
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1 /bin/sh
wget --spider --timeout=1 nginx
```

### test access with access label

```sh
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1 --labels="access=true" /bin/sh
wget --spider --timeout=1 nginx
```

### test access with access label from another namespace

```sh
kubectl create ns other-ns
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1 --labels="access=true" -n other-ns /bin/sh
wget --spider --timeout=1 nginx.default.svc.cluster.local
```

### allow access with access label from every namespaces

```yaml
vim nginx-policy-all-ns.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: access-nginx
spec:
  podSelector:
    matchLabels:
      run: nginx
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: "true"
    - namespaceSelector: {}
```

```sh
kubectl apply -f nginx-policy-all-ns.yaml
```

### test access with access label from another namespace

```sh
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1 --labels="access=true" -n other-ns /bin/sh
wget --spider --timeout=1 nginx.default.svc.cluster.local
```

## Isolate a namespace

```yaml
vim deny-from-other-namespaces.yaml

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: deny-from-other-namespaces
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector: {}
```

```sh

# create ns
kubectl create ns isolated-ns

# create deployment in ns isolated-ns
 kubectl create deployment nginx --image=nginx -n isolated-ns

# create service in ns isolated-ns
kubectl expose deployment nginx --port 80 -n isolated-ns

# test access from another pod default ns (OK)
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1  /bin/sh
wget --spider --timeout=1 nginx.isolated-ns.svc.cluster.local

# isolate the namespace
kubectl apply -f deny-from-other-namespaces.yaml -n isolated-ns

# test access from another pod default ns (KO)
kubectl run busybox --rm -ti --image=busybox --generator=run-pod/v1  /bin/sh
wget --spider --timeout=1 nginx.isolated-ns.svc.cluster.local

```

## Exemples

$ kubectl create deployment nginx --image=nginx

*Un podSelector vide sélectionne tous les pods de l'espace de noms.
* chaque politique NetworkPolicy comprend une liste policyTypes pouvant inclure Ingress , Egress ou les deux.Si aucun type de policyTypes n'est spécifié sur un NetworkPolicy, par défaut, Ingress sera toujours défini et Egress sera défini si NetworkPolicy a des règles de sortie.

```yaml
apiVersion: extensions/v1beta1
kind: NetworkPolicy
metadata:
   name: policyfrontend
   namespace: tst
spec:
   podSelector:
      matchLabels:
         app: nginx
  policyTypes: 
  -   Ingress 
  -   Egress 
  ingress:	 
   - from:
      - podSelector:
         matchLabels:
            role: db
   ports:
      - protocol: TCP
         port: 6379
egress: 
  -   to: 
    -   ipBlock: 
        cidr:   10.0.0.0/24 
    ports: 
    -   protocol:   TCP 
      port:   5978
```



- Le NetworkPolicy isole les pods identifiés par le label "role=backend" dans le namespace "tst" pour le trafic entrant "Ingress" et sortant "Egress". Sur le reste des Pods du namesapce, elle identifie ceux contenant le label "role=db" et leurs autorise les connexions entrante sur le port TCP 6379 sur les Pods avec le lable "role:backend".



voir: https://kubernetes.io/docs/concepts/services-networking/network-policies/

