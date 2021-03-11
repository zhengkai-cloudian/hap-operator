# HAP-Operator

## Overview

Hap Operator runs on a kubernetes cluster. This documents demonstrates the practical steps to create single and multi-node installation of kubernetes cluster and running HAP operator.

*Hap Operator expects to have a Cloudian Hyperstore installed and running* as the applications intended to run inside the HAP Operator (and on kubernetes cluster) may use Cloudian Hyperstore services such as S3 for storing the data. You can follow the official [installation guide]((https://github.com/cloudian/hap-operator/tree/master/docs)) to install Cloudian Hyperstore.

## Installation Steps In-Brief

The overall high level installation steps -

1. Install CentOS (preferably with Cloudian ISO)
2. Create Kubernetes Cluster
3. Deploy Hap-Operator

## Prerequisites

Before you start, *you should have all your nodes built with Cloudian provided ISOs*. If you want to use your own ISO, makes sure following are turned off or disabled permanently. Cloudian ISOs are already preconfigured with these setting though.  

1. Disable Firewall
2. Disable SELinux
3. Disable Iptables

```
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo setenforce 0
```
Starting with CentOS 7, FirewallD replaces iptables as the default firewall management tool. So after disabling firewall, iptables should also be turned off. To disable Iptables -
```
sudo iptables -F
```

## Install CentOS

If you have performed the installation of Cloudian Hyperstore, you may already have created at least a single node with Cloudian provided ISO of CentOS and can skip to [Install Kubernetes](https://github.com/cloudian/hap-operator#install-kubernetes). You may also choose your own choice of Linux. 

You need atleast single node to create kubernetes cluster. It is a good practice to have at least 3 nodes/VMs to create a stable kubernetes cluster.

Hap Operator is designed to run parallely on the same node with your hyperstore. Therefore, choose one of the node in your Cloudian Hyperstore cluster as master node to create kubernetes cluster. 

## Install Kubernetes

To create a kubernetes cluster in the CentOS environment, you need to configure some basic setup on every node.

* **Step 1 to 7 on every node** 
* **Step 8 to 11 only on master node**
* **Step 12 on master node if you have single node cluster**

### Step 1: Configure Kubernetes Repository

Kubernetes packages are not available from official CentOS 7 repositories. This step needs to be performed on the Master Node, and each Worker Node you plan on utilizing for your container setup. Enter the following command to retrieve the Kubernetes repositories.
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg 
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
### Step 2: Install Docker

Install, enable and start docker.
```
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
```
Also, verify that docker version is 1.12 and greater using 
```
docker version
```

### Step 3: Make sure the SELinux and Firewall are disabled

The containers need to access the host filesystem. SELinux needs to be set to permissive mode, which effectively disables its security functions. If you already have the HyperStore running, that means you've has already disabled and skips this step. You can cofirm it by runnign following steps -
```
# check SELinux
sudo getenforce

# check firewall
sudo firewall-cmd --state
```
If you find that one of these are running, please go through the [Overview](https://github.com/cloudian/hap-operator#prerequisites) section once.

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

### Step 7: Enable & Start kubelet 
```
sudo systemctl enable kubelet
sudo systemctl start kubelet
```

### Step 8: Create cluster with kubeadm

Execute following series of commands as `root` to create kubernetes cluster.
```
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
If after running command `kubectl get nodes` shows anyof your node-status as **NotReady**, please wait for some time as the required images are still being pulled. Meanwhile you may want to check your nodes using `kubectl describe your-node-name`.

### Step 11: Install pod network on Kubernetes cluster
```
sudo kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
```

### Step 12: Run To Create Single Node Cluster

This creates a single node kubernetes cluster. Therefore run this step only if you wish to have a single node kubernetes cluster where master also works as worker. By default, the pod will not be scheduled on master. To make master schedule the pod(s) -
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
  kubectl apply -f deploy/crds/hap.cloudian.com_hapcontainers_crd.yaml
  kubectl apply -f deploy/service_account.yaml
  kubectl apply -f deploy/role.yaml
  kubectl apply -f deploy/role_binding.yaml
  kubectl apply -f deploy/operator.yaml
```

4. The following command creates hapcontainer object in the cluster -

```
$ kubectl apply -f deploy/crds/hap.cloudian.com_v1alpha1_hapcontainer_cr.yaml
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

### Run ML Applications in Jupyter

1. Note the IP address of the node where the pod is running from the following command
```
  $ kubectl describe pod example-hapcontainer-happod
```
2. Note the node port of the service where the application is running from the following command
```
  $ kubectl describe service example-hapcontainer-hapservice
```
3. Type the IP address along with port in the browser to view Jupyter notebook

4. Login with password "root" to view the applications MaskClassifier and FacialRecognitionUnmasked

5. Existing Python code in the directory can be run by creating a notebook and executing the following command

```
    %run -i <ProgramName>
```
### Run Spark Applications in container

1. Start the container shell 
```
  $ kubectl exec -it example-hapcontainer-happod -- /bin/bash
```
2. Scp data into the pod 
```
  $ kubectl cp <file-spec-src> <file-spec-dest> -c <specific-container>
```
Example 1: Copy /tmp/foo local file to /tmp/bar in a remote pod in namespace 
```
  $ kubectl cp /tmp/foo <some-namespace>/<some-pod>:/tmp/bar
```
Example 2: Copy /tmp/foo from a remote pod to /tmp/bar locally
```
  $ kubectl cp <some-namespace>/<some-pod>:/tmp/foo /tmp/bar
```

3. Run spark-submit for your application
```
  $ spark-submit \
    --master local[*] \
    --deploy-mode client \
    --class com.cloudian.hap.qct.AirDetection \
    applications/hap-air-detection/target/scala-2.11/qct-air-detection-assembly-0.1.jar
```
here `*` controls the number of cores allocation to the application

4. Access spark webUI
```
  $ kubectl get svc
```
Use the noteport exposed in mapping with node `4040` and access spark UI at `node-ip:nodeport` in your browser. Ex `10.10.3.72:31665` where `31665` is nodeport service for `4040`.

5. To create and access UI, deploy Presto on kubernetes from [presto-on-k8s](https://github.com/cloudian/presto-on-k8s) 

### Creating Air Detection UI:
Air Detection UI consists of PrestoSql query engine and Redash dashboard. Presto needs a hive metastore to store the metadata for the tables and data stored on S3 buckets. 

![Presto-S3 Setup Logical View Architecture](https://github.com/cloudian/hap-operator/blob/master/images/PrestoSql.jpeg)

### Architecture explained:

In order for Presto to query data on S3, it relies on the Hive Metastore. Therefore, we first configure a Hive Standalone Metastore and then separately the Presto servers. Presto and Hive do not make copy of S3 data, they only create pointers enabling performant queries.

**Component 1: RDBMS for Metastore:** Hive Metastore is the external table, a common tool that connects an existing dataset on S3 without requiring ingestion into the data warehouse, instead querying the data in-place.  backed by a MariaDB container with kubernetes persistent volume. An initschema is important to be run once during initial setup of the backing database. Hive library has schematool already setupinside the docker image for this process. 

**Component 2: Standalong Hive Metastore:** This uses mysql and hadoop libraries for s3a connections by setting configurations related to S3 into core-site.xml file and mysql mariadb into metastore-site.xml.

**Component 3: Presto Servers:** Presto works in a cluster of coordinator and workers. Both coord and worker nodes are connected to S3 via hive.properties file that controls connectivity to S3.

**Component 4: Redash:** Redash is an open-source UI for creating SQL queries and dashboards against Presto. 

## Cleaning up the resources

Use the following command to delete all the resources created
```
  $ kubectl delete -f deploy/service_account.yaml
  $ kubectl delete -f deploy/role.yaml
  $ kubectl delete -f deploy/role_binding.yaml
  $ kubectl delete -f deploy/crds/hap.cloudian.com_hapcontainers_crd.yaml
  $ kubectl delete -f deploy/operator.yaml
  $ kubectl delete -f deploy/crds/hap.cloudian.com_v1alpha1_hapcontainer_cr.yaml
```
