# Snapshot ETCD

## certificats etcd
Copier les certificats etcd (par défaut dans le répertoire ```/etc/kubernetes/pki/etcd/``` sur le master pour un cluster créé avec kubeadm) sur les worker

## adapter le yaml

Modifier la déclaration des volumes pour les faire correspondre à vos worker

[etcd-snapshot.yaml](TP\etcd-snapshot.yaml)

## créer le pod

```sh
kubectl apply -f etcd-snapshot.yaml
```

## rentrer dans le conteneur

```
kubectl exec -it etcd-snapshot sh
```

## exécuter le backup via la commande suivante 



```sh

# verification du montage du volume contenant les certificats ca.crt,server.crt et server.key
ls /etc/kubernetes/pki/etcd/

# verification du montage du volume de sauvegarde (peut être vide)
ls -al /etcd-snapshot 


# URL du endpoints ETCD (à adapter)
endpoints=https://192.169.32.20:2379

# mettre la valorisation de variable d'environnement sur la MEME ligne que la commande
ETCDCTL_API=3 etcdctl --endpoints=$endpoints --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /etcd-snapshot/snapshotdb
