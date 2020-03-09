# HAP-Operator 

## Overview

## Prerequisites

Hyperstore installed with 3 node cluster. 

## Quickstart

### Create Kubernetes Cluster

Follow the steps to install and configure the HAP Operator for kubernetes.

1. Run k8s\_setup.sh on every node
2. Run k8s\_master\_setup.sh on master node and save the `kubeadm join` message so as to add the worker nodes
3. Run ```kubeadm join``` generated from previous step. 
4. ```$ kubectl cluster-info``` to confirm that cluster is running
5. ```$ kubectl get nodes``` to confirm that nodes worker nodes have joined the cluster

Note: In case you have any errors in setting up k8s cluster, you can run ```$ kubeadm reset```` to reset the master and run the master script again.  

[In progress]
