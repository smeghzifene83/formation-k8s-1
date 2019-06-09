# Installation un ensemble de 3 VM

## Description

This project allow to init a multi machines cluster to test K8s.
Platorm is provisioned and initialized with vagrant and VirtualBox

- master
- node1
- node2

## vagrant command

### Init the cluster
In the folder of your choice
vagrant up

### Stop
All the cluster
```vagrant halt```

A machine
```vagrant halt <machine-name>```

### Connection
vagrant ssh <machine-name>

## Config
### IP
The static IP are in the .\provision\etc_hosts_extend file used to init  /etc/hosts of each machine (to be improved)

### Composant installer sur chaque VM

- docker
- kubeadm, kubectl, kubelet