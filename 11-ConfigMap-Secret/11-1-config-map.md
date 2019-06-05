```
kubectl create configmap docker-demo-env-file --from-env-file=docker-demo-env-file.properties
kubectl apply -f docker-demo-config-map.yaml
kubectl exec docker-demo-69644cdc8d-2gr7x env
kubectl exec docker-demo-69644cdc8d-2gr7x sh
    wget -qO- http://localhost:8080/ping

kubectl get pod -o wide
curl http://<POD_IP>:8080/ping

kubectl apply -f docker-demo-service-ClusterIP.yaml
kubectl get svc
curl http://<SVC_IP>:8080/ping

kubectl apply -f docker-demo-ingress.yaml 
```