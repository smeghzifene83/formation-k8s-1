# Commande (Entrypoint) et arguments (Cmd)

1/ Définir une commande (Entrypoint) et des arguments (Cmd) pour un conteneur:
La commande et les arguments définis ne peuvent pas être modifiés après la création du Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod2
spec:
  containers:
  - name: container2
    image: centos
    command: ["printenv"]
    args: ["HOSTNAME", "KUBERNETES_PORT"]
  restartPolicy: OnFailure
```
```
$ kubectl create -f https://github.com/dlevray/kubernetes/blob/master/TP/simplepod2.yaml
```

Pour voir la sortie de la commande exécutée dans le conteneur, affichez les journaux du Pod:
```
$ kubectl logs simplepod2
```

Créer un nouveau Pod et exécuter une commande dans un shell:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod3
spec:
  containers:
  - name: container3
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
  restartPolicy: OnFailure
```

```
$ kubectl create -f https://github.com/dlevray/kubernetes/blob/master/TP/simplepod3.yaml
```
