# HAP-Operator

## Overview

This documents demonstrates the practical steps to create single and multi-node installation of Cloudian HyperStore, create kubernetes cluster and run HAP operator init.

## Installation Steps In-Brief

The overall high level installation steps -

1. Install CentOS 7.6 (preferably with Cloudian ISO)
2. Install HyperStore
3. Install Kubernetes
4. Install Hap-Operator

## Prerequisites

Before you start, **you should have all your nodes or VMs build with Cloudian provided ISOs**. If you want to use your own ISO, makes sure following are turned off or disabled permanently. Cloudian ISOs are already preconfigured with these setting though.  
```
1. Firewall
2. SELinux
3. Iptables
```
To disable the Firewall -
```
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```
To disable SELinux -
```
sudo setenforce 0
```
Starting with CentOS 7, FirewallD replaces iptables as the default firewall management tool. So after disabling firewall, iptables should also of turned off. To disable Iptables -
```
sudo iptables -F
```

## HyperStore Installation Introduction

If you do not yet have the HyperStore package, you can obtain it from the Cloudian FTP site ftp.cloudian.com. You will need a login ID and password (available from Cloudian Support). Once logged into the FTP site, change into the Cloudian_HyperStore directory and then into the cloudian-7.2 sub-directory. From there you can download the HyperStore software package, which is named `CloudianHyperStore-7.2.bin`.

To install and run HyperStore software you need a HyperStore license file usually found in **CloudianPackage/** directory.

**NOTE** If you do not have the license file yet, please Send an email to cloudian-license@cloudian.com With the following parameters:

```
Net Storage:
Expiration:
Maximum Tiered Storage:
Object Lock Mode:
```
For example:
```
Net Storage: 50 TB
Expiration: 2 Years
Maximum Tiered Storage: 10TB
Object Lock Mode: Enabled
```

To install the CloudianHyperstore, follow the **CloudianHyperStore Install Guide** instructions that you will find in the **docs/** inside the package you have downloaded. In case it is missing, the same install guide is provided in the [docs](https://github.com/cloudian/hap-operator/tree/master/docs) with this repo.

## Install Kubernetes

To create a kubernetes cluster in the CentOS environment, you need to configure some basic setup on every node.

* Perform **Step 1 to Step 7 on each node** that you wish to add into the kubernetes cluster.
* Perform **Step 8 to Step 11 on the master node**.
* Perform **Step 12 on master node only if you have single node cluster**.

### Step 1: Configure Kubernetes Repository

Kubernetes packages are not available from official CentOS 7 repositories. This step needs to be performed on the Master Node, and each Worker Node you plan on utilizing for your container setup. Enter the following command to retrieve the Kubernetes repositories.
```
$ cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
### Step 2: Docker installation

Install, enable and start docker.
```
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
```
Also, verify that docker version is 1.12 and greater.

### Step 3: Make sure the SELinux and Firewall are disabled

The containers need to access the host filesystem. SELinux needs to be set to permissive mode, which effectively disables its security functions. If you already have the HyperStore running, that means you've has already disabled. You can cofirm it by runnign following steps -
```
# check SELinux
sudo getenforce

# check firewall
sudo firewall-cmd --state
```
If you find that one of these are running, please go through the overview section once.

### Step 4: Install kubernetes component

Install kubeadm, kubelet and kubectl on CentOS.
```
sudo yum install -y kubelet kubeadm kubectl
```

### Step 5: Update Iptables Settings

Set the net.bridge.bridge-nf-call-iptables to ‘1’ in your sysctl config file. This ensures that packets are properly processed by IP tables during filtering and port forwarding.
```
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EOF

sudo sysctl --system
```

### Step 6: Disable SWAP

Lastly disable the SWAP to enable kubernetes to work properly:
```
sudo swapoff -a
```

### Step 7: Enable kubelet and start kubelet as process
```
sudo systemctl enable kubelet
sudo systemctl start kubelet
```

NOTE: Perform following steps only on the node you wish to make a master node for Kubernetes Cluster

### Step 8: Create cluster with kubeadm

Execute following series of commands as `root` to create kubernetes cluster.

```
touch kubeMasterOutput.txt

# init will pull the images
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address <IP-Address-of-your-node> --ignore-preflight-errors=NumCPU
```
This will generate a `kubeadm join` message in following format -
```
kubeadm join <IP>:<port> --token <token-value> --discovery-token-ca-cert-hash sha256:<discovery-token>
```
Copy and execute the complete `kubeadm join` command on each of the worker nodes. Also keep this message/command saved for future use by prospective worker nodes.

IMPORTANT: If in any case your execution fails in such a way that either master node fails to create the cluster network or worker node fails to join the network, run `$ kubeadm reset` and the error should resolve.

### Step 9: Change the ownership and deploy network protocol

It is advised to change the ownership of kubernetes config directory so that non-root users can make deployment of different services.

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```
### Step 10: Check cluster status

```
kubectl cluster-info  #to check the cluster status.
kubectl get nodes     #to confirm that nodes worker nodes have joined the cluster.
```

### Step 11: Install pod network add-on `Calico` on Kubernetes
```
kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
```

### Step 12: Create Single Node Cluster

This creates a single node kubernetes cluster. Therefore run this step only if you wish to have a single node kubernetes cluster where master also works as worker. By default, the pod will not be scheduled on master. To make master schedule the pod(s)
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Setup for Operator

Follow the steps to install and configure Operator on master node of Kubernetes cluster.

1. Install GO as per your environment from golang official docs [https://golang.org/dl/]
2. Install operator-sdk following instructions from the following Github repo https://github.com/operator-framework/operator-sdk/blob/master/doc/user/install-operator-sdk.md
3. Download hap-operator source and move into the hap-operator directory
4. To deploy the operator to the cluster, execute the following commands.

The following commands install the CRD, set permissions for controller to access Kubernetes API and help in deploying the operator.
```
  $ kubectl apply -f deploy/crds/cloudian.com_hapcontainers_crd.yaml
  $ kubectl apply -f deploy/service_account.yaml
  $ kubectl apply -f deploy/role.yaml
  $ kubectl apply -f deploy/role_binding.yaml
  $ kubectl apply -f deploy/operator.yaml
```

4. The following command creates hapcontainer object in the cluster -

```
$ kubectl apply -f deploy/crds/cloudian.com_v1_hapcontainer_cr.yaml
```

5. We can verify if the operator pod and pod with the image is running by the following command

```
$ kubectl get pods
```
The output should be similar to the following with both the operator and the container pod running
```
   NAME                                     READY   STATUS    RESTARTS   AGE
   example-hapcontainer-happod              1/1     Running   0          121m
   hap-operator-6d6f854c9c-g7hhh            1/1     Running   0          145m
```

If the status of the hap container pod is in **ContainerCreating**, we should wait for few more minutes and check until it changes to **Running**.

 6. Once the container is **Running**, we can check whether the container has the needed libraries(Spark, Tensorflow) installed by getting a shell to the running container.

```
    $ kubectl exec -it example-hapcontainer-happod /bin/bash
```
Inside the container shell, check spark installation by executing

```
    $ spark-shell
```
The output would look like this -
```
    20/03/14 01:13:25 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java       classes where applicable
    Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
    Setting default log level to "WARN".
    To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
    Spark context Web UI available at http://example-hapcontainer-happod:4040
    Spark context available as 'sc' (master = local[*], app id = local-1584148409863).
    Spark session available as 'spark'.
    Welcome to
          ____              __
         / __/__  ___ _____/ /__
        _\ \/ _ \/ _ `/ __/  '_/
       /___/ .__/\_,_/_/ /_/\_\   version 3.0.0-preview2
          /_/

    Using Scala version 2.12.10 (OpenJDK 64-Bit Server VM, Java 1.8.0_242)
    Type in expressions to have them evaluated.
    Type :help for more information.

    scala>
```
Check Tensorflow installation by the following command
```    
    $ pip show tensorflow
```  
The output should look as:
```
    Name: tensorflow
    Version: 2.1.0
    Summary: TensorFlow is an open source machine learning framework for everyone.
    Home-page: https://www.tensorflow.org/
    Author: Google Inc.
    Author-email: packages@tensorflow.org
    License: Apache 2.0
    Location: /usr/local/lib/python3.6/dist-packages
```

7.  When a pod is deleted, new pod is automatically added. You can test this by explicitly deleting using the following command

```
$ kubectl delete pods example-hapcontainer-happod
```
Check if new pod is created
```
$ kubectl get pods
```
You should see a new pod up and running

### Cleaning up the resources

Use the following command to delete all the resources created
```
  $ kubectl delete -f deploy/service_account.yaml
  $ kubectl delete -f deploy/role.yaml
  $ kubectl delete -f deploy/role_binding.yaml
  $ kubectl delete -f deploy/crds/cloudian.com_hapcontainers_crd.yaml
  $ kubectl delete -f deploy/operator.yaml
  $ kubectl delete -f deploy/crds/cloudian.com_v1_hapcontainer_cr.yaml
```
