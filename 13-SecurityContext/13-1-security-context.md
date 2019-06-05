
# Security Context

1/ Créer un Pod et configurer un contexte de sécurité (mode privilége) pour l'ensemble de ses pods:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod6
  namespace: tst
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 2000
    #seLinuxOptions:
      #level: "s0:c123,c456"
      #supplementalGroups: [5678]
  containers:
  - name: container6
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
```
*runAsUser: spécifie que pour tous les conteneur du Pod, le premier processus s'exécute avec l'ID utilisateur 1000. 
*fsGroup: spécifie que l'ID de groupe 2000 est associé à tous les Conteneurs du Pod (L'ID de groupe est également associé au volume monté).


2/ Obtenez un shell et dressez la liste des processus en cours pour vérifier que les processus s'exécutent en tant qu'utilisateur 1000
```bash
$  kubectl exec -it simplepod6 -- sh 
$  ps aux 
```

3/ Créer un fichier dans le répertoire de votre volume et vérifier la valeur de l'ID de groupe

4/ affichez les capacités du processus 1:
```bash
$ cd /proc/1
```


5/ Faites de même pour un contenair:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod6
  namespace: tst
spec:
  containers:
  - name: container6
    image: centos
    securityContext:
      privileged: true
      runAsUser: 2000
      seLinuxOptions:
        level: "s0:c123,c456"
      allowPrivilegeEscalation: false
      capabilities:
	add: ["NET_ADMIN", "SYS_TIME"]
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
```
