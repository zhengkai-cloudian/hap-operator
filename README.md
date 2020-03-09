# HAP-Operator 

## Overview

## Prerequisites

Hyperstore installed with 3 node cluster. 

## Quickstart

### Install the hap-operator 

Follow the steps to install and configure the HAP Operator for kubernetes.

1. Run k8s\_setup.sh on every node
2. Run k8s\_master\_setup.sh on master node and save the `kubeadm join` message so as to add the worker nodes
3. Run ```kubeadm join``` generated from previous step. 
3. ```kubectl cluster-info``` to confirm that cluster is running
4. ```kubectl get nodes``` to confirm that nodes worker nodes have joined the cluster


[In progress]
