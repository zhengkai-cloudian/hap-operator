# HAP-Operator

## Overview

## Prerequisites

Hyperstore installed with 3 node cluster.

## HyperStore Installation Introduction

If you do not yet have the HyperStore 7.2 package, you can obtain it from the Cloudian FTP site ftp.cloudian.com. You will need a login ID and password (available from Cloudian Support). Once logged into the FTP
site, change into the Cloudian_HyperStore directory and then into the cloudian-7.2 sub-directory. From there you can download the HyperStore software package, which is named `CloudianHyperStore-7.2.bin`

To install and run HyperStore software you need a HyperStore license file - either an evaluation license or a production license.

## Preparing Your environment

* DNS Set-Up
* Load Balancing

### DNS Set-Up

For your HyperStore system to be accessible to external clients, you must configure your DNS name servers with entries for the HyperStore service endpoints. Cloudian recommends that you complete your DNS configuration prior to installing the HyperStore system. This section describes the required DNS entries.

If you are doing just a small evaluation and do not require that external clients be able to access any of the HyperStore services, you have the option of using the lightweight domain resolution utility `dnsmasq` which comes bundled with HyperStore -- rather than configuring your DNS environment to support HyperStore service endpoints. If you're going to use `dnsmasq` you can skip ahead to "Preparing Your Nodes"

```
s3-tokyo.enterprise.com IN A 10.1.1.1
                             10.1.1.2
                             10.1.1.3
*.s3-tokyo.enterprise.com IN A 10.1.1.1
                               10.1.1.2
                               10.1.1.3
s3-website-tokyo.enterprise.com IN A 10.1.1.1
                                     10.1.1.2
                                     10.1.1.3
*.s3-website-tokyo.enterprise.com IN A 10.1.1.1
                                       10.1.1.2
                                       10.1.1.3
s3-admin.enterprise.com IN A 10.1.1.1
                             10.1.1.2
                             10.1.1.3
cmc.enterprise.com IN A 10.1.1.1
```




### Load Balancingd



### Create Kubernetes Cluster

Follow the steps to install and configure the Kubernetes Cluster for HAP.

1. Make every node ready for kubernetes by running ```./k8s\_setup.sh``` on every node of hyperstore. This will install the basic libraries on the node.
2. Open the ```k8s\_master\_setup.sh``` script and set up the IP address of the node you wish to set kubernetes master.
3. Run ```./k8s\_master\_setup.sh``` on one of the Hyperstore node you want to make Kubernetes master.
4. This script will generate message like follows which should be saved for later use -
```
kubeadm join 10.10.3.70:6443 --token kr0ke4.r05jox8m57wxi9vm --discovery-token-ca-cert-hash sha256:fc24e04ad8f0754cdc73ae905506c5e1b4a5e4482938d73d667664be9af9ff6a
```

5. Execute output from previous command on the terminal of every single worker node.
6. Run ```$ kubectl cluster-info``` to check the cluster status.
7. Run ```$ kubectl get nodes``` to confirm that nodes worker nodes have joined the cluster.

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
