# SERVICES

Lorsque k8s démarre un conteneur, il fournit des variables d'environnement pointant vers tous les services en cours d'exécution 
Si un service existe, tous les conteneurs recevront les variables
Ne spécifiez pas de hostPort pour un Pod, sauf si cela est absolument nécessaire. (Limite le nombre d'endroits où le Pod peut être planifié, car chaque hostIP < hostIP , hostPort , protocol > doit être unique)
 Si vous ne spécifiez pas explicitement le hostIP et le protocol , k8s utilise 0.0.0.0 comme hostIP par défaut et TCP comme protocol
Si vous avez seulement besoin d'accéder au port à des fins de débogage, vous pouvez utiliser le proxy kubectl port-forward
Si vous avez explicitement besoin d'exposer le port d'un Pod sur le nœud, envisagez d'utiliser un service NodePort avant de recourir à hostPort .
Évitez d'utiliser hostNetwork , pour les mêmes raisons que hostPort .
Utilisez les services sans ClusterIP  pour faciliter la découverte du service lorsque vous n'avez pas besoin de l'équilibrage.


1/ Service avec ou sans Selector:
```yaml
apiVersion: v1
kind: Service
metadata:
   name: My_Service
spec:
   selector: # falcultatif: Contraint à créer un Endpoint pour transférer le trafic
      application: "My Application"  
   ports:
   - port: 8080
   targetPort: 31999
```
*Dans cet exemple, nous avons un sélecteur; Pour transférer le trafic, nous devons donc créer manuellement un EndPoint
-créer un EndPoint qui acheminera le trafic vers le node final défini comme "192.168.168.40:8080".
```yaml
apiVersion: v1
kind: Endpoints
metadata:
   name: Tutorial_point_service
subnets:
   address:
      "ip": "192.168.168.40" -------------------> (Selector)
   ports:
      - port: 8080
```

2/ Service multi-ports:
```yaml
piVersion: v1
kind: Service
metadata:
   name: Tutorial_point_service
spec:
   selector:
      application: “My Application”
   ClusterIP: 10.3.0.12
   ports:
      -name: http
      protocol: TCP
      port: 80
      targetPort: 31999
   -name:https
      Protocol: TCP
      Port: 443
      targetPort: 31998
```      
*CLUSTERIP: Expose (restreindre) le service a l'interieur du cluster.       
      
      
3/ Créer un service complet "NodePort". 
*Un service ClusterIP, auquel ce service "NodePort" acheminera les flux est automatiquement créé. Le service est accéssible de l'extérieur à l'aide de :  NodeIP:NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
   name: My-service
   labels:
      k8s-app: appname
spec:
   type: NodePort   #Expose le service sur un port statique du node
   ports:
   - port: 8080
      nodePort: 31999
      name: Name-NodePord-Service
      #clusterIP: 10.10.10.10
   selector:
      k8s-app: appname
      component: nginx
      env: env_name
```   

