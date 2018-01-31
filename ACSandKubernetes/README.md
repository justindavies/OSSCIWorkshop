# AKS deployment on Azure

## Create resource group for container registry

```
➜  KubeOnAzure (master) ✗ az group create -n kubeonazure-backing -l eastus
Location    Name
----------  -------------------
eastus     kubeonazure-backing
```

```
➜  OSSCIWorkshop git:(master) ✗ az acr create -n judaregistry -g kubeonazure-backing --sku Premium --admin-enabled true

Create a new service principal and assign access:
  az ad sp create-for-rbac --scopes /subscriptions/63bb1026-{snip}-fecb3/resourceGroups/kubeonazure-backing/providers/Microsoft.ContainerRegistry/registries/judaregistry --role Owner --password <password>

Use an existing service principal and assign access:
  az role assignment create --scope /subscriptions/63bb1026-{snip}-fecb3/resourceGroups/kubeonazure-backing/providers/Microsoft.ContainerRegistry/registries/judaregistry --role Owner --assignee <app-id>
NAME          RESOURCE GROUP       LOCATION     SKU      LOGIN SERVER             CREATION DATE                     ADMIN ENABLED    STATUS
------------  -------------------  -----------  -------  -----------------------  --------------------------------  ---------------  --------
judaregistry  kubeonazure-backing  eastus     Premium  judaregistry.azurecr.io  2018-01-30T12:29:00.906107+00:00  True             None
```


```
➜  OSSCIWorkshop git:(master) ✗ az acr credential show -n judaregistry
USERNAME      PASSWORD                          PASSWORD2
------------  --------------------------------  --------------------------------
judaregistry  dC4S1kq0XDR=CGjH7FuDduhMEKRxoScf  Q89hOZwwLBhrbcuiy+lrdJMnjU2KJZl8
```

## Create AKS cluster

Firstly, create a resource group to hold the cluster

```
➜  ~ az group create -n kube -l eastus
Location    Name
----------  ------
eastus      kube
```

And create a Kubernetes cluster with the default settings (3 agent nodes, D1v2 type)

```
➜  ~ az aks create -n juda -g kube
 - Running ..
{
  "agentPoolProfiles": [
    {
      "count": 3,
      "dnsPrefix": null,
      "fqdn": null,
      "name": "nodepool1",
      "osDiskSizeGb": null,
      "osType": "Linux",
      "ports": null,
      "storageProfile": "ManagedDisks",
      "vmSize": "Standard_D1_v2",
      "vnetSubnetId": null
    }
  ],
  "dnsPrefix": "juda-kube-63bb10",
  "fqdn": "juda-kube-63bb10-d43f1ed7.hcp.eastus.azmk8s.io",
  "id": "/subscriptions/63bb1026-{snip}-8b343eefecb3/resourcegroups/kube/providers/Microsoft.ContainerService/managedClusters/juda",
  "kubernetesVersion": "1.7.7",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa AAAAB3NzaC1yc-{snip}-wFDAH8E7Rz"
        }
      ]
    }
  },
  "location": "eastus",
  "name": "juda",
  "provisioningState": "Succeeded",
  "resourceGroup": "kube",
  "servicePrincipalProfile": {
    "clientId": "5a77a46a-{snip}-ce371de0cecf",
    "keyVaultSecretRef": null,
    "secret": null
  },
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters"
}
```

## Install the Kubernetes CLI

Once provisioning is complete, we need to instal the *kubectl* command line, as well as pull down the cluster context.

NOTE: *kubectl* is installed as default in the Cloud Shell.

```
➜  ~ az aks install-cli
Downloading client to /Users/juda/.kube/config from https://storage.googleapis.com/kubernetes-release/release/v1.9.2/bin/darwin/amd64/kubectl
```

### Merge contexts
```
az aks get-credentials --n juda -g kube
Merged "juda" as current context in /home/justin/.kube/config
```

## Check everything looks good

Let's do a simple query against the cluster to check the agent node status.

```
kubectl get no
NAME                       STATUS    ROLES     AGE       VERSION
aks-nodepool1-22565329-0   Ready     agent     2m        v1.7.7
aks-nodepool1-22565329-1   Ready     agent     2m        v1.7.7
aks-nodepool1-22565329-2   Ready     agent     2m        v1.7.7
```

## Smoke test time!

Use the kubectl command to do a simple deploy of the nginx docker image, with two replicas.

```
kubectl run my-nginx --image=nginx --replicas=2 --port=80
deployment "my-nginx" created
```

### Check the pods

```
kubectl get pods
NAME                        READY     STATUS    RESTARTS   AGE
my-nginx-4293833666-jlq9q   1/1       Running   0          28s
my-nginx-4293833666-sr9pb   1/1       Running   0          28s
```

### Check the deployment
```
kubectl get deployment
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-nginx   2         2         2            2           59s
```

### Publish the deployment as a Service
```
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer
service "my-nginx" exposed
```

### Check the Service is available
Exposing the deployment through a Service will take a little time as the "type=LoadBalancer" will instantiate an Azure LoadBalancer in front of your deployment and attache a public IP address.

```
kubectl get svc
NAME         TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
kubernetes   ClusterIP      10.0.0.1     <none>          443/TCP        14m
my-nginx     LoadBalancer   10.0.6.125   40.71.227.131   80:31324/TCP   7m
```