# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "controller" do |controller|
    controller.vm.hostname = "controller"
    controller.vm.box = "bento/ubuntu-20.04"
    controller.vm.network "private_network", ip: "10.10.0.2"
    controller.vm.synced_folder ".", "/vagrant"
    controller.vm.boot_timeout = 600
    controller.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    controller.vm.provision "ansible" do |ansible|
      ansible.playbook = "controller-init.yml"
    end
  end 

  config.vm.define "aws" do |aws|
    aws.vm.hostname = "aws"
    aws.vm.box = "bento/ubuntu-20.04"
    aws.vm.synced_folder ".", "/vagrant"
    aws.vm.network "private_network", ip: "10.10.0.100"
    aws.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 2
    end
    aws.vm.provision "ansible" do |ansible|
      ansible.playbook = "vagrant-init.yml"
    end
  end 

end
