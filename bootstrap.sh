#!/bin/bash

## !IMPORTANT ##
#
## This script is tested only in the generic/ubuntu2204 Vagrant box
## If you use a different version of Ubuntu or a different Ubuntu Vagrant box test this again
#
echo "#########BOOTSTRAPING VMs#########"
echo "[TASK 1] DISABLE AND TURN OFF SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] STOP AND DISABLE FIREWALL"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] ENABLE AND LOAD KERNEL MODULES"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 4] ADD KERNEL SETTINGS"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

 echo "[TASK 5] ADD APT REPO FOR KUBERNETES AND CONTAINERD"
apt install ca-certificates curl gnupg lsb-release >/dev/null 2>&1
apt-add-repository "deb https://download.docker.com/linux/ubuntu/ jammy stable" >/dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - >/dev/null 2>&1
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "[TASK 6] INSTALL CONTAINERD RUNTIME"
apt update -qq >/dev/null 2>&1
apt install -qq -y containerd.io apt-transport-https >/dev/null 2>&1
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml 
systemctl restart containerd
systemctl enable containerd 

echo "[TASK 7] INSTALL KUBERNETES COMPONENTS (KUBEADM, KUBELET AND KUBECTL)"
apt install -qq -y kubeadm=1.26.1-00 kubelet=1.26.1-00 kubectl=1.26.1-00 >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl
echo "[TASK 8] SETTING SSH ROOT LOGIN, PASS & PUBKEY AUTHENTICATION "
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "/^[^#]*ChallengeResponseAuthentication[[:space:]]yes/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd >/dev/null 2>&1

echo "[TASK 9] SETTING ROOT PASSWORD"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc >/dev/null 2>&1

echo "[TASK 10] UPDATE /ETC/HOSTS FILE"
cat >>/etc/hosts<<EOF
172.16.16.100   master
172.16.16.101   worker1
172.16.16.102   worker2
172.16.16.103   worker3
EOF

echo "[TASK 11]  INSTALLING AND ACTIVATING K8S AUTO-COMPLETION & ALIASES"
apt-get install bash-completion >/dev/null 2>&1
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null 
echo 'alias k=kubectl' >>/home/vagrant/.bashrc 
echo 'complete -o default -F __start_kubectl k' >>/home/vagrant/.bashrc 
exec bash 

echo "[TASK 12] CHANGING KEYBOARD TO LATAM"
sed -i '/XKBLAYOUT/s/".*"/"latam"/' /etc/default/keyboard >/dev/null 2>&1
echo loadkeys latam >> /home/vagrant/.bashrc >/dev/null 2>&1
systemctl restart keyboard-setup.service >/dev/null 2>&1

echo "[TASK 13] SETTING TIMEZONE TO MEXICO CITY" 
timedatectl set-timezone America/Mexico_City >/dev/null 2>&1

echo "[TASK 14] FIXING RUNTIME-ENDPOINT FOR CRICTL"
crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock