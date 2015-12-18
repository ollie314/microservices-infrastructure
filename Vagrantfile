# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

VAGRANT_PRIVATE_IP_CONTROL_01 = "192.168.242.55"
VAGRANT_PRIVATE_IP_WORKER_001 = "192.168.242.56"

Vagrant.configure(2) do |config|
  # Prefer VirtualBox before VMware Fusion
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"
  config.vm.box = "centos/7"
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--cpus', 1]
    vb.customize ['modifyvm', :id, '--memory', 1024]
  end

  # Disable shared folder(s) for workers
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/home/vagrant/sync', disabled: true

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  # This machine will be provisioned via the other
  config.vm.define "worker" do |worker|
      worker.vm.hostname = "worker-001"
      worker.vm.network "private_network", :ip => VAGRANT_PRIVATE_IP_WORKER_001
  end

  config.vm.define "control" do |control|
      # Enable shared folder(s) for provisioner, which needs Mantl source
      control.vm.synced_folder ".", "/vagrant", type: "rsync"
      control.vm.hostname = "control-01"
      control.vm.network "private_network", :ip => VAGRANT_PRIVATE_IP_CONTROL_01
      control.vm.provision "shell" do |s|
        s.path = "vagrant/provision.sh"
        s.args = [VAGRANT_PRIVATE_IP_CONTROL_01, VAGRANT_PRIVATE_IP_WORKER_001]
      end
  end
end
