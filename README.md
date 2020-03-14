# HAP-Operator

## Overview

## Prerequisites

Check the minimum requirement section.

## HyperStore Installation Introduction

If you do not yet have the HyperStore 7.2 package, you can obtain it from the Cloudian FTP site ftp.cloudian.com. You will need a login ID and password (available from Cloudian Support). Once logged into the FTP site, change into the Cloudian_HyperStore directory and then into the cloudian-7.2 sub-directory. From there you can download the HyperStore software package, which is named `CloudianHyperStore-7.2.bin`

To install and run HyperStore software you need a HyperStore license file - either an evaluation license or a production license.

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

**IMPORTANT** It is advised to use the admin installation guide that comes with the Cloudian HyperStore package you have downloaded. You can refer the installation process from that in case you need detailed instruction to configure installation. A sample admin guide has already been added in the [docs](https://github.com/cloudian/hap-operator/tree/master/docs) section this github repo for 7.2.  

## Host Hardware and OS Requirements

Both single and multi-node are similar in configuration during installation.

### Recommended for Production system:

* 1 CPU, 8 cores
* 128GB RAM
* 2 x 960GB SSD (for RAID-1 mirrored hosting of the OS as well as Cassandra and Redis databases storing system metadata)
* 12 x 4TB HDD (for ext4 file systems storing object data) (JBOD, no RAID)
* 2 x 10GbE Ports

### Minimum for production systems:

* 1 CPU, 8 cores
* 64 GB RAM
* 2 x 480GB SSD (for RAID-1 mirrored hosting of the OS as well as Cassandra and Redis databases storing system metadata)
* 12 x 4TB HDD (for ext4 file systems storing object data) (JBOD, no RAID)
* 2 x 10GbE Ports

### Minimum for Software Installation :

HyperStore software can be installed on a single host that has just one data drive. The host should have at least 1GB of hard drive space, at least 32GB RAM, and preferably at least 8 processor cores. If you install HyperStore software on a host with less resources than this, the install script will display a warning about the host having less than recommended resources.

If you try to install HyperStore software on a host with less 100MB hard drive space or less than 2GB RAM, the installation will abort.

**IMPORTANT** Our official minimum requirement is 3 nodes. If you only have one node (recommended and used for the testing purposes only), you don't have data protection.  

Then complete these node preparation tasks in this order:
1. Installing HyperStore Prerequisites
2. Configuring Network Interfaces, Time Zone, and Data Disks
3. Running the Pre-Install Checks Script

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

### Load Balancing

If you are building your nodes using Cloudian ISO, load balancer will be automatically installed and configured. You are required to configure it otherwise.

## Preparing Your Node

To prepare your hosts for HyperStore software Installation:

First confirm that each host meets HyperStore "Host Hardware and OS Requirements"

## Operating System Requirements

To install HyperStore 7.2 you must have a RHEL 7.x or CentOS 7.x Linux operating system on each host. HyperStore 7.2 does not support installation on RHEL/CentOS 6.x . Also, HyperStore does not support other
types of Linux distribution, or non-Linux operating systems. If you have not already done so, install RHEL 7.x or CentOS 7.x in accordance with your hardware manufacturer's recommendations.

To install HyperStore the following services must be disabled on each HyperStore host machine:

* firewalld
* iptables
* SELinux

To disable firewalld:

```
[root]# systemctl stop firewalld
[root]# systemctl disable firewalld
```

RHEL/Centos7 uses firewalld by default rather than the iptables service (firewall uses iptables commands but the iptables service itself is not instlaled on RHEL/CentOS by default). So you do not need to take actions in regard to iptables unless you installed and enabled the iptables service on your hotss. If that's the case, then disable the iptables service.

To disable SELinux, edit the configuration file /etc/selinux/config so that SELINUX=disabled. Save your change and then restart the host.

### Python 2.7.x is Required

If you are building your nodes using Cloudian ISO, Python 2.7.x will be automatically installed and configured. In case you want to use some different ISO, the HyperStore installer requires Python version 2.7.x. The installer will abort with an error message if any host is using Python 3.x.

## Installing HyperStore Prerequisites

Follow these steps to install and configure HyperStore prerequisites on all of your nodes. Working from a
single node you will be able to perform this task for your whole cluster.

1. Log into one of your nodes as root. This will be the node from which you will orchestrate the HyperStore installation for your whole cluster. Also, as part of the HyperStore installation, Puppet configuration management software will be installed and configured in the cluster, and this node will become the "Puppet Master" node for purposes of ongoing cluster configuration management. Note that the Puppet Master
node must be one of your HyperStore nodes. It cannot be a separate node outside of your HyperStore cluster.
2. On the node that you've chosen to become your Puppet Master node, download or copy the HyperStore product package (CloudianHyperStore-7.2.bin file) into any directory. Also copy your Cloudian license file (\*.lic file) into that same directory. Pay attention to the license file name since you will need the file name in the next step.
3. In that directory run the commands below to unpack the HyperStore package

```
[any-directory]# chmod +x CloudianHyperStore-7.2.bin
[any-directory]# ./CloudianHyperStore-7.2.bin <license-file-name>
```
This creates an installation staging directory named /opt/cloudian-staging/7.2, and extracts the HyperStore package contents into the staging directory.

Note: The installation staging directory must persist for the life of your HyperStore system. Do not delete the staging directory after completing the install.

4. Change into the installation staging directory:
 ```
 [any-directory]# cd /opt/cloudian-staging/7.2
 ```

5. In the staging directory, launch the system_setup.sh tool:
```
[7.2]# ./system_setup.sh
```
This displays the tool's main menu.

6. From the setup tool's main menu, enter "4" for Setup Survey.csv file and follow theprompts to create a cluster Survey file with an entry for each of your HyperStore nodes (including the Puppet Maste node). For each node you will enter a region name, hostname, public IP address, data center name, and rack name.

* For each node the hostname that you enter must exactly match the node's hostname -- as would be returned by running the hostname command on the node.
* For the region, data center, and rack name the only allowed character types are ASCII alphanumerical characters and dashes. For the region name letters must be lower case.
* Within a data center, use the same "rack name" for all of the nodes, even if some nodes are on different physical racks than others.
* Make sure the region name matches the region string that you use in your S3 endpoints in your "DNS Set-Up".

7. If you want to change the root password for your nodes, do so now by entering "5" for Change Root Password and following the prompts. It's recommended to use the same password for each node. Otherwise the pre-installation cluster validation tool described later in the procedure will not be fully functional.

8. Back at the setup tool's main menu enter "6" for Install & Configure Prerequisites. When prompted about whether you want to perform this action for all nodes in your survey file enter "yes". The tool will
connect to each of your nodes in turn and install the prerequisite packages. You will be prompted to provide the root password either for the whole cluster (if, as recommended, each node has the same
root password) or for each node in turn (if the nodes have different passwords). When the prerequisite installation completes for all nodes, return to the setup tool's main menu.

Note: If `firewalld` is running on your hosts the setup tool prompts you for permission to disable it. And if Selinux is enabled on your hosts, the tool automatically disables it without prompting for
permission (or more specifically, changes it to "permissive" mode for the current running session and changes the configuration so it will be disabled for future boots of the hosts).

## Configuring Network Interfaces, Time Zone, and Data Disks

Having finished "Installing HyperStore Prerequisites" (page 12), you should be at the main menu of the system_setup.sh tool, in the installation directory on your Puppet Master node. Next follow these steps to configure
network interfaces (if you haven't already fully configured them), set the time zone, and configure data disks on each node in your HyperStore cluster.

1. On the Puppet Master node, from the system setup tool's main menu, complete the setup of the Puppet Master node itself:

    a. From the system setup tool's main menu, enter "1" for Configure Networking. This displays the Networking configuration menu.
    ```
    Here you can review the current network interface configuration for the Puppet Master node, and if you wish, perform additional configuration such as configuring an internal/back-end interface. When you are done with any desired network interface configuration changes for this node, return to the setup tool's main menu
    ```
    b. At the setup tool's main menu, enter "2" for setting timezone.

    c. Enter "3" for Setup Disks.

    From the list of disks on the node select the disks to format as HyperStore data disks, for storage of S3 object data. By default the tool automatically selects all disks that are not already mounted and do not contain a /root, /boot or [swap] mount indication. Selected disks display in green font in the disk list. The tool will format these disks with ext4 file systems and assign them mount points /cloudian1, /cloudian2, /cloudian3, and so on. You can toggle (select/deselect) a disk by entering at the prompt the disk's number from the displayed list (such as "3"). Once you're satisfied with the selected list in green font, enter "c" for Configure Selected Disks and follow the prompts to have the tool configure the selected disks.

2. Next, complete the setup of the other nodes in your cluster:

    a. From the setup tool's main menu select "9" for Prep New Node to Add to Cluster.

    b. When prompted enter the IP address of one of the remaining nodes (the nodes other than the Puppet Master node), and then enter the login password for the node.

    c. Using the node preparation menu that displays:

        i. Review and complete network interface configuration for the node.
        ii. Set the time zone for the node.
        iii. Configure data disks for the node. Then return to the system setup tool's main menu.

    d. Repeat Steps "a" through "c" for each of the remaining nodes in your installation cluster.  

After you've prepared all your nodes and returned to the setup tool's main menu, proceed to "Running the PreInstall Checks Script"

## Running the Pre-Install Checks Script

Follow these steps to verify that your cluster now meets all HyperStore requirement for hardware, prerequisite packages and network connectivity.

1. At the setup tool's main menu enter "r" for Run Pre-Installation Checks. This displays the Pre-Installation Checklist menu.
2. From the Pre-Installation Checklist menu enter "r" for Run Pre-Install Checks. The script then checks to verify that your cluster meets all requirements for hardware, prerequisite packages, and network connectivity. At the end of its run the script outputs to the console a list of items that the script has evaluated and the results of the evaluation. You should review any “Warning” items but they don’t necessarily require action (an example is if the hardware specs are less than recommended but still adequate for the installation to proceed). You must resolve any “Error” items before performing the HyperStore software installation, or the installation will fail.
3. When you’re done reviewing the results, press any key to continue and then exit the setup script. If you make any system changes to resolve errors found by the pre-install check, run the pre-install check again afterward to verify that your environment meets HyperStore requirements.

After your cluster has successfully passed the pre-install checks, proceed to "Installing a New HyperStore System"

## Installing a New Hyperstore System

This section describes how to do a fresh installation of HyperStore 7.2 software, after "Preparing Your Environment" and "Preparing Your Nodes". From your Puppet Master node you can install HyperStore software across your whole cluster.

1. On your Puppet Master node, in your installation staging directory, launch the HyperStore installation script as follows:

```
[7.2]# ./cloudianInstall.sh -s survey.csv
```
```
Note If you have not configured your DNS environment for HyperStore (see "DNS Set-Up" (page 4))
and you want to instead use the included dnsmasq utility to resolve HyperStore service endpoints,
launch the install script with the configure-dnsmasq option as shown below.
This is not appropriate for production systems.

[ 7.2]# ./cloudianInstall.sh -s survey.csv configure-dnsmasq
```
**NOTE** If you are doing a single node installation, you will have to use `force` flag in above command.

When you launch the installer the main menu displays:

```
   Cloudian HyperStore(R) 7.2 Installation/configuration
  -------------------------------------------------------
  0 )   Run Pre-Installed Checks
  1 )   Install Cloudian HyperStore
  2 )   Cluster Management
  3 )   Upgrade From a Previous Version
  4 )   Advanced Configuration Options
  5 )   Uninstall Cloudian HyperStore
  6 )   Help
  7 )   Exit
```

2. From the installer main menu, enter "1" for Install Cloudian HyperStore. Follow the prompts to perform the HyperStore installation across all the nodes in your cluster survey file (which you created earlier during the node preparation task)

During the HyperStore installation you will be prompted to provide the following cluster configuration information:

* The name of the internal interface that your nodes will use by default for internal cluster communications. For example, eth1. Cassandra, Redis, and the HyperStore Service are among the services that will utilize the internal interface for intra-cluster communications.
* The starting "replication strategy" that you want to use to protect system metadata (such as usage reporting data and user account information). The replication strategy you enter must be formatted as "<datacenter_name>:<replication_#>". For example, "DC1:3" means that in the data center named DC1, three instances of each system metadata object will be stored (with each instance on a different host). If you are installing HyperStore into multiple data centers you must format this as a comma-separated list specifying the replicas per data center -- for example "DC1:2,DC2:1". The default is 3 replicas per service region, and then subsequently the system automatically adjusts the system metadata replication level based on the storage policies that you create. For more on this topic see "Storage of System Metadata" in the HyperStore Administrator's Guide
* Your organization domain. For example, enterprise.com. From this input that you provide, the installation script will automatically derive HyperStore service endpoint values. You can accept the derived endpoint values that the script presents to you, or optionally you can enter customized endpoint values at the prompts. For S3 service endpoint the default is to have one endpoint per service region, but you also have the option of entering multiple comma-separated endpoints within a service region -- if for example you want different data centers within the region to use different S3 service endpoints. If you want to have different S3 endpoints for different data centers within the same service region, the recommended S3 endpoint syntax is s3-<region>.<dcname>.<domain>. See "DNS Set-Up" (page 4) for more details about HyperStore service endpoints.

At the conclusion of the installation an "Install Cloudian HyperStore" sub-menu displays, with indication of the installation status. If the installation completed successfully, the "Load Schema and Start Services" menu item should show an "OK" status. After seeing that the "Load Schema and Start Services" status is OK, return to the installer's main menu.

3. After installation has completed successfully, from the installer's main menu enter "2" for Cluster Management and then enter "d" for Run Validation Tests. This executes some basic automated tests to confirm that your HyperStore system is working properly. The tests include S3 operations such as creating an S3 user group, creating an S3 user, creating a storage bucket for that user, and uploading and downloading an S3 object.

After validation tests complete successfully, exit the installation tool.


## Install Kubernetes

To create a kubernetes cluster in the CentOS environment, you need to install some basic setup on every node.

* Perform Step 1 to Step 7 on every node that you wish to add into the kubernetes cluster.
* Perform Step 8 only on the master node.

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
$ sudo yum install -y docker
$ sudo systemctl enable docker && sudo systemctl start docker
```
Also, verify that docker version is 1.12 and greater.

### Step 3: Disable the SELinux and Firewall

The containers need to access the host filesystem. SELinux needs to be set to permissive mode, which effectively disables its security functions. If you already have the HyperStore running, that means you've has already disabled and you can ignore this step.
```
# disable SELinux
$ sudo setenforce 0

# stop firewall
$ sudo systemctl stop firewalld
$ sudo systemctl disable firewalld
```

### Step 4: Install kubernetes component

Install kubeadm, kubelet and kubectl on CentOS.
```
$ sudo yum install -y kubelet kubeadm kubectl
```

### Step 5: Update Iptables Settings

Set the net.bridge.bridge-nf-call-iptables to ‘1’ in your sysctl config file. This ensures that packets are properly processed by IP tables during filtering and port forwarding.
```
$ cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EOF'

$ sudo sysctl --system
```

### Step 6: Disable SWAP

Lastly disable the SWAP to enable kubernetes to work properly:
```
$ sudo swapoff -a
```

### Step 7: Enable kubelet and start kubelete as process
```
sudo systemctl enable kubelet && sudo systemctl start kubelet
```

NOTE: Perform following steps only on the node you wish to make a master node for Kubernetes Cluster

### Step 8: Create cluster with kubeadm

Execute following series of commands as `root` to create kubernetes cluster.

```
$ ls /etc/kubernetes/admin.conf && mv /etc/kubernetes/admin.conf.bak
$ touch kubeMasterOutput.txt
# kubeadm config images pull
# init will pull the images
$ kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address <IP-Address-of-your-node> --ignore-preflight-errors=NumCPU
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
$ kubectl cluster-info  #to check the cluster status.
$ kubectl get nodes     #to confirm that nodes worker nodes have joined the cluster.
```

## Setup for Operator

Follow the steps to install and configure Operator on master node of Kubernetes cluster.

1. Install GO as per your environment from golang official docs [https://golang.org/dl/]
2. Download hap-operator source and move into the hap-operator directory
3. To deploy the operator to the cluster, execute the following commands.

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

    Check Tensorflow installation by the following command
    #pip show tensorflow
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

[In proofread & progress]
