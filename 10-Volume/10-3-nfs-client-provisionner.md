# NFS client provisionner

## Configuration NFS server

1. Make and populate a directory to be shared. Also give it similar permissions to /tmp/

```sh
$ sudo mkdir /opt/nfs-k8s-pv-provisioner
$ sudo chmod 777 /opt/nfs-k8s-pv-provisioner/

```

2. Edit the NFS server file to share out the newly created directory. In this case we will share the directory with all. You can always snoop to see the inbound request in a later step and update the file to be more narrow.

```
$ sudo vim /etc/exports
/opt/nfs-k8s-pv-provisioner/ *(rw,sync,no_root_squash,subtree_check)
```

3. Cause /etc/exports to be re-read:

```
$ sudo exportfs -ra
$ sudo systemctl restart nfs-kernel-server
```


## config nfs-client-provisioner

Pré requis :
- installation et configuration du serveur NFS et des clients nfs sur chaque worker

- acces au catalogue helm (cf. TP Helm)

```sh
kubectl create namespace nfs-cp

helm install stable/nfs-client-provisioner --name my-nfs-cp --namespace nfs-cp -f config-nfs-client-provisioner.yaml

# check
kubectl get all -n nfs-cp
kubectl get storageclasses
```

## use storage class

```yaml

# check the nfs dir
ll /opt/nfs-k8s-pv-provisioner

# create PVC
kubectl apply -f pvc-nfs-dynamique.yaml

# check pvc
kubectl get pvc

# check nfs dir
ll /opt/nfs-k8s-pv-provisioner
```