# Azure Kubernetes Service (AKS) -  Level 200-250 Lab.

## Objectives
This lab is aimed at people who haven't yet used Kubernetes.  It takes you through a step by step installation on Azure using the Azure Kubernetes Service (AKS), and the most common commands and operations to get started with Kubernetes.

Not intended to replace the AKS guides on docs, simply to compliment.
> https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
>
> https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app

Expect this lab to take about 90 minutes.

## Tools required
Exercises 1-6
* Azure Cloud Shell (Bash version) (It's built into the Azure Portal, nothing to install!)

Exercises 7-10
* Bash on a linux OS (or the Linux subsystem for Windows 10)

## Caveats
No Windows, no GUI's.  By that i mean you can of course use the Windows OS, but please use either the
1. Linux subsystem for Windows 10
1. A Linux VM inside Hyper-V.

If you really want to use the Powershell on Windows 7, go for it... But you'll be going off-lab and will likely have issues to resolve that aren't covered in this guide.

## Exercise 1 - Creating a Kubernetes Cluster in Azure.
There are 2 main ways of creating an AKS Cluster.
1. In the Azure Portal GUI
1. Using the Azure CLI

My preference is the *Azure CLI* because it generates the SSH keys for you as well as the service principal.  The easiest way to use the Azure CLI is in Cloud Shell in the Azure Portal. 
Feel free to use the Portal GUI to create the service, but you're going off-lab (but just a little bit so don't worry too much.

Lets open the Cloud Shell.  

> https://portal.azure.com

Login and then click the Cloud Shell icon

![image](./Media/cloud-shell.png) 

You'll then see the Cloud Shell open at the bottom of the screen.

Alternatively, open the cloud shell in it's own window
> https://shell.azure.com/

Copy and paste this script into the Cloud Shell.  It'll do 4 things;
1. Create a resource group called K8S in eastus.
1. Create a AKS cluster with a few specific options set.  You don't have to provide half of these, but i quite like the new B-series VM so we're setting that up.  The default would have been a D2_V2 VM for the agent VM's that get created.  It also would have been 3 agents, but 1 is enough for the time being.
1. Grab the credentials to be able to connect to your cluster.

    ```
    location=eastus
    az group create --name K8s --location $location
    az aks create --resource-group K8s --name K8sCluster --node-count 1 --generate-ssh-keys --node-vm-size=Standard_B2s --disable-rbac
    az aks get-credentials --resource-group=K8s --name=K8sCluster 
    ```

This takes between 7 and 15 minutes to provision.  So lets use this time to watch the Illustrated Children's Guide to Kubernetes.
If you haven't seen this, watching it will take 8 minutes and it does the best job of talking about the Kubernetes constructs that i've seen.  If you have already seen it, i'd encourage a second watch just to let everything sink in.

[![Illustrated Children's Guide to Kubernetes](http://img.youtube.com/vi/4ht22ReBjno/0.jpg)](https://www.youtube.com/watch?v=4ht22ReBjno  "Illustrated Children's Guide to Kubernetes")
https://www.youtube.com/watch?v=4ht22ReBjno

### Post creation
After the cluster has been created, in the Azure Portal find the resource group and open it up.  You'll see a Kubernetes service cluster created

![image](./Media/cluster-created.png) 

## Exercise 2 - kubectl 
Kubectl is the main tool you're going to use to manage your kubernetes cluster.  It comes pre-installed in the Azure Cloud Shell, which is awesome. 

So lets have a look at a basic command that will tell us about the VM's.

```kubectl get nodes```

![image](./Media/get-nodes.png) 

Lets run a couple of other common commands.

```kubectl cluster-info```

![image](./Media/cluster-info.png) 

```kubectl version```

![image](./Media/version.png) 

## Exercise 3 - Creating a simple deployment
We're going to use a YAML file from the Azure Quickstarts.
The YAML file declaratively states the container name location and any other supporting Kubernetes resources needed.  We'll examine the YAML later.

        mkdir ~/clouddrive/aks-yaml
        cd ~/clouddrive/aks-yaml
        curl -O https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml
        kubectl create -f azure-vote-all-in-one-redis.yaml


Once this has created, lets use the following commands to see what's been created ```kubectl get pods``` ```kubectl get svc ```

![image](./Media/azure-vote.png) 
    
We have 2 containers and 2 services.  One of the services is internally exposed, the other will receive a public ip address.
If you use the command ```kubectl get svc -w``` the command console will watch for changes and report them.  So when a public ip address is created in Azure, it'll appear in the console window.

It's important to realise that an actual public ip address has been created
![image](./Media/ip-address.png) 

You can hit this IP address in a browser and interact with the web app that's been created.

## Exercise 4 - YAML
Typically, you would have two types of yaml files to help Kubernetes understand what your applications consist of and how they would operate. These two files would be the deployment and services yaml file. Let's drill down into what roles they have with k8s:

Deployment: According to Kubernetes documentation, the definition of deployment(s) is "You describe a desired state in a Deployment object, and the Deployment controller changes the actual state to the desired state at a controlled rate". In my own words, deployments let you define parameters such as how many replicas your applications will have (how many copies of the container will be spun up for the application), the docker image location of your container and the name of it.  Let's review the two deployment configurations (the azure vote frontend and backend apps) from the yaml file you deployed earlier:

![image](./Media/deployment-yaml.png) 


## Exercise 5 - Autohealing

Run this command and see what pods you have running
    ```kubectl get pods```

Now delete the pod
    ```kubectl delete pod NameOfYourPod```

Run this command again and see what's reported
    ```kubectl get pods -w```
    
I'm expecting that your pod has gone, but a very similarly named one has been put in it's place.
TA-DA.  Autohealing!

![image](./Media/delete-pod.png) 

## Exercise 7 - Working locally

By now, we're all bored of Cloud Shell, sure it's nice and easy.. But every time you go for a coffee, it times out - and we need to consider accessing this from somewhere else.

With ACS this was a little bit of a pain, moving contexts/ssh keys from Cloud Shell to the local linux environment.  Thankfully with AKS, all we have to do is sign in with the ```az login``` com mand and run the ```az aks get-credentials --resource-group=K8s --name=K8sCluster``` command. 

### Installing Kubectl
We need to install Kubectl into your local linux environment.
Follow the appropriate instructions here : https://kubernetes.io/docs/tasks/tools/install-kubectl/


Now you can run the following command to ensure that everything is working.
```kubectl get nodes```


## Exercise 8 - Accessing the dashboard
Kubernetes has a web dashboard, who knew!
Lets have a look

```az aks browse -g K8S -n K8SCluster```

![image](./Media/dashboard.png) 

## Exercise 9 - Creating a deployment in the Dashboard GUI
From within the dashboard, go create then complete the details as per screenshot.
![image](./Media/dash-nginx.png) 

![image](./Media/dash-deployments.png)

Let's back out of the dashboard and run these commands to see what's been created.

```kubectl get pods```

```kubectl get svc```

The get svc command will output something like this;
![image](./Media/nginx-svc.png) 
Where we have an Azure Public IP allocated.  If this doesn't appear you can watch for changes by running the ```kubectl get svc -w``` command, then when you have a public ip allocated you can test it out in your browser.

![image](./Media/nginx-publicip.png) 

## Exercsie 10 - Helm
Helm is a package manager for Kubernetes.  It will simply allow the installation of complex software using *Helm Charts* (are you noticing a terminology theme yet :)).

Please read the introduction section through to the installation section here : https://github.com/kubernetes/helm

Once installed, initialise it.  This will install a tiller pod into the cluster.

```helm init```

Now lets have a quick look at all the things we could install with Helm.  You can also reference the KubeApps site: https://hub.kubeapps.com/

```helm search```

The syntax for installing a package is 

```helm install --name my-blog stable/wordpress```

## Troubleshooting Tips

#### Inspect pod logs
    kubectl logs thenameofyourpod

#### HELM refused to work, because of version Mismatch
    helm incompatible versions client[v2.7.2] server[v2.5.1]
> helm init --upgrade



#### ERROR: Helm init --upgrade doesn't work
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Permissions 0777 for '/root/.ssh/id_rsa' are too open.
    It is required that your private key files are NOT accessible by others.
    This private key will be ignored.
    Load key "/root/.ssh/id_rsa": bad permissions
    Permission denied (publickey).

> chmod 600 /root/.ssh/id_rsa

> ssh azureuser@k8scheapcl-k8scheap-2d5bb2mgmt.westeurope.cloudapp.azure.com sudo sed -i s/'2.5.1'/'2.7.2'/g /etc/kubernetes/addons/kube-tiller-deployment.yaml && helm init --upgrade
    
    $HELM_HOME has been configured at /root/.helm.
    Tiller (the Helm server-side component) has been upgraded to the current version.
    Happy Helming!



####ERROR: Can't retrieve the Server version of HELM after upgrade
    root@MININT-90OLH41:~# helm version
    Client: &version.Version{SemVer:"v2.7.2", GitCommit:"8478fb4fc723885b155c924d1c8c410b7a9444e6", GitTreeState:"clean"}
    Error: cannot connect to Tiller

>REBOOT THE VM's!

####ERROR: Operation failed with status: 'Bad Request'. Details: The value of parameter orchestratorProfile.OrchestratorVersion is invalid.

>Update the OrchestratorVersion in our case is --kubernetes-version to current latest version 1.12.5 for example ( please check Azure documentation to keep up to date : https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster  )
