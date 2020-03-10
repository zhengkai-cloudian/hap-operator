# HAP-Operator

## Overview

## Prerequisites

Hyperstore installed with 3 node cluster.

## Quickstart

### Create Kubernetes Cluster

Follow the steps to install and configure the Kubernetes Cluster for HAP.

1. Make every node ready for kubernetes by running ```./k8s\_setup.sh``` on every node of hyperstore. This will install the basic libraries on the node.
2. Open the ```k8s\_master\_setup.sh``` script and set up the IP address of the node you wish to set kubernetes master.
2. Run ```./k8s\_master\_setup.sh``` on one of the Hyperstore node you want to make Kubernetes master.
3. This script will generate message like follows which should be saved for later use -
```kubeadm join 10.10.3.70:6443 --token kr0ke4.r05jox8m57wxi9vm --discovery-token-ca-cert-hash sha256:fc24e04ad8f0754cdc73ae905506c5e1b4a5e4482938d73d667664be9af9ff6a
```
4. Execute output from previous command on the terminal of every single worker node.
4. Run ```$ kubectl cluster-info``` to check the cluster status.
5. Run ```$ kubectl get nodes``` to confirm that nodes worker nodes have joined the cluster.

Note: In case you have any errors in setting up k8s cluster, you can run ```$ kubeadm reset``` to reset the master and run the master script again.  

### Setup for Operator

Follow the steps to install and configure Operator on master node of Kubernetes

1. Install GO as per your environment from goland officla docs [https://golang.org/dl/]
2. Download hap-operator source and move into the `hap-operator` directory
3. If your k8s cluster is running and setup properly, setup RBAC and deploy the operator:
```
$ kubectl create -f deploy/service_account.yaml
$ kubectl create -f deploy/role.yaml
$ kubectl create -f deploy/role_binding.yaml
$ kubectl create -f deploy/operator.yaml
```
NOTE: To apply the RBAC you need to be logged in as `root`

Verify that the `hap-operator` deployment is up and running:
```
$ kubectl get deployment
NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hap-operator             1         1         1            1           1m
```

Verify that the `hap-operator` pod is up and running:
```
$ kubectl get pod
NAME                                  READY     STATUS    RESTARTS   AGE
hap-operator-7d76948766-nrcp7         1/1       Running   0          24s
```
If you want to check the logs of your operator:
```
$ kubectl logs hap-operator-7d76948766-nrcp7
```

### running application on kubernetes

Running an application in the kubernetes using operator includes following steps:
1. Create CustomResourceDefinition for the application
2. Create Controller for the application
3. Deploy the CRD using kubectl.

[In progress]
