#!/bin/bash
echo "##########CONFIGURING WORKER##########"
echo "[TASK I] JOINING NODE TO CLUSTER"
whoami
apt install -qq -y sshpass >/dev/null 2>&1
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.16.16.100:/joincluster.sh /joincluster.sh 2>/dev/null
bash /joincluster.sh >/dev/null 2>&1

echo "[TASK II] SETUP KUBECTL IN WORKER"
sudo -u vagrant mkdir -p /home/vagrant/.kube >/dev/null 2>&1
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.16.16.100:/home/vagrant/.kube/config /home/vagrant/.kube/config >/dev/null 2>&1
sudo chown vagrant:vagrant /home/vagrant/.kube/config >/dev/null 2>&1

# echo "[TASK III] EXTRACTING RSA PUBKEY FROM MASTER FOR ROOT & VAGRANT"
# sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@172.16.16.100 cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys >/dev/null 2>&1
# sshpass -p "kubeadmin" ssh -o StrictHostKeyChecking=no root@172.16.16.100 cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys >/dev/null 2>&1


