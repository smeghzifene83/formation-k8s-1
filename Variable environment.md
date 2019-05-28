---------------------------------------------------------------------------------------------------------------
## Variables d'environnement 
---------------------------------------------------------------------------------------------------------------

1/ Utiliser les variables d'environnement pour définir les arguments:
```yaml
env:
- name: MESSAGE
  value: "hello world"
command: ["/bin/echo"]
args: ["$(MESSAGE)"]
```
* incluez le champ "env" ou "envFrom" dans le fichier de configuration.
* Les variables d'environnement définies à l'aide du champ "env" ou "envFrom" remplacent toutes les variables d'environnement spécifiées dans l'image du conteneur.
*On peut définir un argument pour un Pod en utilisant des variables d'environnement, y compris les ConfigMaps et Secrets.



2/ Définir une variable d'environnement pour un conteneur:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: MyPod
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: MyContainer
    image: Centos
    env:
    - name: MyVar1
      value: "Hello World"
    - name: MyVar2
      value: "Hello Formation"
```

-Créer le Pod et connectez vous dessus. Dans le shell, exécutez la commande "printenv" pour lister les variables d'environnement.



3/ Utiliser les champs "Pod" comme valeurs pour les variables d'environnement:
Un Pod peut utiliser des variables d'environnement pour exposer des informations sur lui-même aux Conteneurs s'exécutant dans ce même Pod. Les variables d'environnement peuvent exposer les champs Pod et les champs Conteneur. Il existe deux façons d'exposer les champs Pod et Conteneur à un conteneur en cours d'exécution:
-Variables d'environnement
-DownwardAPIVolumeFiles
* ces deux façons d'exposer les champs Pod et Conteneur s'appellent l' API Downward .

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: MyPod
spec:
  containers:
    - name: Mycontainer
      image: centos
      command: [ "sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          printenv MY_NODE_NAME MY_POD_NAME MY_POD_NAMESPACE;
          printenv MY_POD_IP MY_POD_SERVICE_ACCOUNT;
          sleep 10;
        done;
      env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
  restartPolicy: Never
```

-Créer le Pod et afficher les journaux du conteneur:
```
$  kubectl logs dapi-envars-fieldref 
```
* Le premier élément du tableau spécifie que la variable "MY_NODE_NAME" tire sa valeur du champ "spec.nodeName" du Pod. 
* De même, les autres variables d'environnement obtiennent leurs noms des autres champs Pod.



4/ Utiliser les champs "Conteneur" comme valeurs pour les variables d'environnement:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: MyPod
spec:
  containers:
    - name: Mycontainer
      image: centos
      command: [ "sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          printenv MY_CPU_REQUEST MY_CPU_LIMIT;
          printenv MY_MEM_REQUEST MY_MEM_LIMIT;
          sleep 10;
        done;
      resources:
        requests:
          memory: "32Mi"
          cpu: "125m"
        limits:
          memory: "64Mi"
          cpu: "250m"
      env:
        - name: MY_CPU_REQUEST
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: requests.cpu
        - name: MY_CPU_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: limits.cpu
        - name: MY_MEM_REQUEST
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: requests.memory
        - name: MY_MEM_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: limits.memory
  restartPolicy: Never
```
* Le premier élément du tableau spécifie que la variable "MY_CPU_REQUEST" tire sa valeur du champ "MY_CPU_REQUEST" d'un conteneur nommé test-container . 
* De même, les autres variables d'environnement obtiennent leurs valeurs à partir des champs Container.



5/ Stocké des champs Pod dans un DownwardAPIVolumeFile:
Un Pod peut utiliser un DownwardAPIVolumeFile pour exposer des informations sur lui-même à des Conteneurs s'exécutant dans le Pod:
Un DownwardAPIVolumeFile peut exposer les champs Pod et les champs Conteneur

Stocker les champs Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubernetes-downwardapi-volume-example
  labels:
    zone: us-est-coast
    cluster: test-cluster1
    rack: rack-22
  annotations:
    build: two
    builder: john-doe
spec:
  containers:
    - name: client-container
      image: k8s.gcr.io/busybox
      command: ["sh", "-c"]
      args:
      - while true; do
          if [[ -e /etc/podinfo/labels ]]; then
            echo -en '\n\n'; cat /etc/podinfo/labels; fi;
          if [[ -e /etc/podinfo/annotations ]]; then
            echo -en '\n\n'; cat /etc/podinfo/annotations; fi;
          sleep 5;
        done;
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
          readOnly: false
  volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: "labels"
            fieldRef:
              fieldPath: metadata.labels
          - path: "annotations"
            fieldRef:
              fieldPath: metadata.annotations
```
vous pouvez voir que le pod a un volume /etc/podinfo et que le conteneur monte le volume dans /etc/podinfo .
Regardez le tableau des items sous downwardAPI . 
Chaque élément du tableau est un DownwardAPIVolumeFile . 
Le premier élément spécifie que la valeur du champ metadata.labels du Pod doit être stockée dans un fichier nommé labels . 
Le second élément spécifie que la valeur du champ d' annotations du Pod doit être stockée dans un fichier nommé annotations .


vous stockez les champs Conteneur dans un DownwardAPIVolumeFile:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubernetes-downwardapi-volume-example-2
spec:
  containers:
    - name: client-container
      image: k8s.gcr.io/busybox:1.24
      command: ["sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          if [[ -e /etc/podinfo/cpu_limit ]]; then
            echo -en '\n'; cat /etc/podinfo/cpu_limit; fi;
          if [[ -e /etc/podinfo/cpu_request ]]; then
            echo -en '\n'; cat /etc/podinfo/cpu_request; fi;
          if [[ -e /etc/podinfo/mem_limit ]]; then
            echo -en '\n'; cat /etc/podinfo/mem_limit; fi;
          if [[ -e /etc/podinfo/mem_request ]]; then
            echo -en '\n'; cat /etc/podinfo/mem_request; fi;
          sleep 5;
        done;
      resources:
        requests:
          memory: "32Mi"
          cpu: "125m"
        limits:
          memory: "64Mi"
          cpu: "250m"
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
          readOnly: false
  volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: "cpu_limit"
            resourceFieldRef:
              containerName: client-container
              resource: limits.cpu
          - path: "cpu_request"
            resourceFieldRef:
              containerName: client-container
              resource: requests.cpu
          - path: "mem_limit"
            resourceFieldRef:
              containerName: client-container
              resource: limits.memory
          - path: "mem_request"
            resourceFieldRef:
              containerName: client-container
              resource: requests.memory
```
vous pouvez voir que le pod a un volume /etc/podinfo et que le conteneur monte le volume dans /etc/podinfo .
Regardez le tableau des items sous downwardAPI . 
Chaque élément du tableau est un DownwardAPIVolumeFile.
Le premier élément spécifie que dans le conteneur nommé client-container , la valeur du champ limits.cpu doit être stockée dans un fichier nommé cpu_limit .



Capacités de l'API Downward:
Les informations suivantes sont disponibles pour les conteneurs via les variables d'environnement et DownwardAPIVolumeFiles:
- Le nom du nœud
- L'adresse IP du nœud
- Le nom du Pod
- L'espace de noms du Pod
- L'adresse IP du Pod
- Le nom du compte de service du pod
- L'UID du Pod
- Limite du processeur d'un conteneur
- Demande de CPU d'un conteneur
- Limite de mémoire d'un conteneur
- Demande de mémoire d'un conteneur

En outre, les informations suivantes sont disponibles via DownwardAPIVolumeFiles.
- Les Labels du Pod
- Les Annotations du Pod
