#/bin/sh
ls /etc/kubernetes/admin.conf && mv /etc/kubernetes/admin.conf.bak

touch kubeMasterOutput.txt


#kubeadm config images pull
#init will pull the images
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address 10.10.1.197 --ignore-preflight-errors=NumCPU

sleep 30

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#https://github.com/coreos/flannel/blob/master/Documentation/kubernetes.md
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-legacy.yml

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
#kubectl apply -f /etc/hyperview/ymls/kube-flannel.yml
#kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml

