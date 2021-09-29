# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "vpn-center" do |v|
    v.vm.hostname = "vpn-center"
    v.vm.box = "ubuntu/focal64"
    v.vm.network "private_network", ip: "203.0.113.10", virtualbox__intnet: "global_internet"
    # 2001:db8::10/64
    
    v.vm.synced_folder "./", "/vagrant", type: "rsync", rsync__exclude: ".git/"
    v.vm.provider "virtualbox" do |vm|
      vm.memory = 512
      vm.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end
    v.vm.provision "shell", inline: "sh /vagrant/vpn-center.sh"
  end

  config.vm.define "vpn-client00" do |v|
    v.vm.hostname = "vpn-client00"
    v.vm.box = "ubuntu/focal64"
    v.vm.network "private_network", ip: "203.0.113.20", virtualbox__intnet: "global_internet"
    # 2001:db8::20/64

    v.vm.synced_folder "./", "/vagrant", type: "rsync", rsync__exclude: ".git/"
    v.vm.provider "virtualbox" do |vm|
      vm.memory = 512
      vm.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end
    v.vm.provision "shell", inline: "sh /vagrant/vpn-client00.sh"
  end

  config.vm.define "vpn-client01" do |v|
    v.vm.hostname = "vpn-client01"
    v.vm.box = "ubuntu/focal64"
    v.vm.network "private_network", ip: "203.0.113.30", virtualbox__intnet: "global_internet"
    # 2001:db8::30/64

    v.vm.synced_folder "./", "/vagrant", type: "rsync", rsync__exclude: ".git/"
    v.vm.provider "virtualbox" do |vm|
      vm.memory = 512
      vm.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end
    v.vm.provision "shell", inline: "sh /vagrant/vpn-client01.sh"
  end

end
