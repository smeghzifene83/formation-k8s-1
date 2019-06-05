# install K8s on AWS IaaS with kubeadm

## key

Connect with ssh on the VM


```
export PUBLIC_IP=52.47.81.140
export INTERNAL_IP=$(hostname -i)
```
##

--apiserver-cert-extra-sans=$PUBLIC_IP



warning : [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/


## display token
