
---------------------------------------------------------------------------------------------------------------
## NETWORK POLICY:
---------------------------------------------------------------------------------------------------------------

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

