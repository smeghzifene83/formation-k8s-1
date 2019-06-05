
---------------------------------------------------------------------------------------------------------------
## Affectation Pod
---------------------------------------------------------------------------------------------------------------

1/ répertoriez les nodes disponibles sur le cluster:
```bash
$ kubectl get nodes 
```

2/ Ajouter les labels au node:
```bash
$ kubectl label nodes node1 disk=ssd
```

3/ Vérifiez que le node possède bien le nouveau label : 
```bash
$  kubectl get nodes --show-labels 
```

4/ Créer un pod "simplepod4" planifié sur le node choisi grace au sélecteur de node (node qui a un label label1=var1):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod4
  namespace: tst
spec:
  restartPolicy: Never
  nodeSelector:
    disk: ssd
  containers:
  - name: container4
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
```
```bash
$ kubectl create -f simplepod4.yaml
```

5/ Vérifiez que le pod est bien en cours d'exécution sur le node choisi:
```bash
$ kubectl get pods --output=wide 
```
