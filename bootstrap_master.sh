#!/bin/bash
echo "##########CONFIGURING MASTER##########"
echo "[TASK I] PULL REQUIRED CONTAINERS"
kubeadm config images pull >/dev/null

echo "[TASK II] INITIALIZE KUBERNETES CLUSTER"
kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[TASK III] DEPLOY CALICO NETWORK"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml >/dev/null 

echo "[TASK IV] GENERATE AND SAVE CLUSTER JOIN COMMAND TO /JOINCLUSTER.SH"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK V] SETUP KUBECTL IN MASTER"
sudo -u vagrant mkdir -p /home/vagrant/.kube >/dev/null 
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config >/dev/null 
sudo chown vagrant:vagrant /home/vagrant/.kube/config >/dev/null 

# echo "[TASK VI] GENERATING SSH PUBKEY WITH PASSPHRASE"
# ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa <<<y >/dev/null 2>&1
# sudo -u vagrant ssh-keygen -q -t rsa -N '' -f /home/vagrant/.ssh/id_rsa <<<y >/dev/null 2>&1