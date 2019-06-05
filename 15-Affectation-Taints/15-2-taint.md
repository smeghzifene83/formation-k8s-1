---------------------------------------------------------------------------------------------------------------
## Taints:
---------------------------------------------------------------------------------------------------------------

1/ Ajoutez un taints à un node:
```bash
$ kubectl taint nodes node1 Mykey=Myvalue:NoSchedule
$ kubectl describe no node1 | grep Taints
```
*L'affectation "Mykey=Myvalue:NoSchedule" au node signifie qu'aucun pod ne pourra être planifier sur node1, à moins d'avoir une tolérance correspondante.


2/ Lancer un nouveau pod "simplepod5" sur le node1 et vérifier le status:
```bash
$ kubectl describe po  simplepod5
```

3/ Spécifiez l'une des tolérances ci-dessous dans le PodSpec du simplepod5 (Operateur: Equal ou Exist) afin que celui-ci soit capable d'être programmé sur node1 :
```yaml
spec:
  tolerations:
  - key: "Mykey"
    operator: "Equal"
    value: "Myvalue"
    effect: "NoSchedule"

ou

tolerations:
- key: "key"
  operator: "Exists"
  effect: "NoSchedule"
```
*Une tolérance "correspond" à une taint si les clés sont les mêmes et les effets sont les mêmes
*Deux cas spéciaux:
 - Une key vide avec opérateur "Exists" correspond à toutes les clés, valeurs et effets, ce qui signifie que tout sera toléré.
```yaml
tolerations:
- operator: "Exists"
```

 - Un effect vide correspond à tous les effets avec la key “Mykey” .
```yaml
tolerations:
- key: "Mykey"
  operator: "Exists"
```


2/ Supprimer l'altération sur le node:
```bash
$ kubectl taint nodes node1 Mykey:NoSchedule-
```


Voir: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/

