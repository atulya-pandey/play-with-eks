## Blue-Green-Deployment

Some useful links:
https://blog.powerupcloud.com/automate-blue-green-deployment-on-kubernetes-in-a-single-pipeline-part-x-3b2e598d778e
&nbsp;
https://github.com/IanLewis/kubernetes-bluegreen-deployment-tutorial
https://www.ianlewis.org/en/bluegreen-deployments-kubernetes

```bash
$ kubectl apply -f Blue-Green-Deployment/k8s/blue-deployment.yaml

$ kubectl apply -f Blue-Green-Deployment/k8s/service.yaml

$ kubectl apply -f Blue-Green-Deployment/k8s/green-deployment.yaml

$ kubectl patch svc mywebapp -p "$(cat Blue-Green-Deployment/k8s/patch.yaml)"

$ kubectl delete -f Blue-Green-Deployment/k8s/blue-deployment.yaml
```

More documentation and information upcoming. Till then, sit back and relax !!