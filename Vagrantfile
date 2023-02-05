# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "generic/ubuntu2204" #OS IMAGE 
VAGRANT_BOX_VERSION = "4.2.10"             #
CPUS_MASTER_NODE    = 2                    #AMOUNT OF CORES FOR MASTER
CPUS_WORKER_NODE    = 1                    #AMOUNT OF CORES FOR WORKERS
MEMORY_MASTER_NODE  = 2048                 #RAM FOR MASTER
MEMORY_WORKER_NODE  = 1536                 #RAM FOR WORKERS
WORKER_NODES_COUNT  = 3                    #AMOUNT OF WORKER NODES


Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  # Kubernetes Master Server
  config.vm.define "master" do |node|
  
    node.vm.box               = VAGRANT_BOX
    node.vm.box_check_update  = false
    node.vm.box_version       = VAGRANT_BOX_VERSION
    node.vm.hostname          = "master"

    node.vm.network "private_network", ip: "172.16.16.100"
  
    node.vm.provider :virtualbox do |v|
      v.name    = "master"
      v.memory  = MEMORY_MASTER_NODE
      v.cpus    = CPUS_MASTER_NODE
    end
  
    node.vm.provider :libvirt do |v|
      v.memory  = MEMORY_MASTER_NODE
      v.nested  = true
      v.cpus    = CPUS_MASTER_NODE
    end
    node.vm.provision "setup-dns", type: "shell", :path => "update-dns.sh"
    node.vm.provision "shell", path: "bootstrap_master.sh"
  
  end

  
  # Kubernetes Worker Nodes
  (1..WORKER_NODES_COUNT).each do |i|

    config.vm.define "worker#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.box_version       = VAGRANT_BOX_VERSION
      node.vm.hostname          = "worker#{i}"

      node.vm.network "private_network", ip: "172.16.16.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "worker#{i}"
        v.memory  = MEMORY_WORKER_NODE
        v.cpus    = CPUS_WORKER_NODE
      end

      node.vm.provider :libvirt do |v|
        v.memory  = MEMORY_WORKER_NODE
        v.nested  = true
        v.cpus    = CPUS_WORKER_NODE
      end
      node.vm.provision "setup-dns", type: "shell", :path => "update-dns.sh"
      node.vm.provision "shell", path: "bootstrap_worker.sh"

    end

  end

end
