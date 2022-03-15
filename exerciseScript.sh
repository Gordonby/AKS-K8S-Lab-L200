location=eastus
az group create --name K8s --location $location
az aks create --resource-group K8s --name K8sCluster --node-count 1 --generate-ssh-keys --node-vm-size=Standard_B2s --disable-rbac
az aks get-credentials --resource-group=K8s --name=K8sCluster

 kubectl create -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml

 kubectl get pods

 kubectl get svc

 kubectl get nodes

 kubectl run my-nginx --image nginx --restart Never --dry-run=client -o yaml
