# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "vagrant-win81x64-enterprise"
  config.vm.box = "win81x64-enterprise"

  # Port forward WinRM and RDP
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct:true
  config.vm.communicator = "winrm"
  config.vm.guest = :windows
  config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct:true
  # Port forward SSH
  #config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct:true

  config.vm.provider :virtualbox do |v, override|
    v.gui = true
    v.customize ["modifyvm", :id, "--memory", 1536]
    v.customize ["modifyvm", :id, "--cpus", 1]
    v.customize ["modifyvm", :id, "--vram", "256"]
    v.customize ["setextradata", "global", "GUI/MaxGuestResolution", "any"]
    v.customize ["setextradata", :id, "CustomVideoMode1", "1024x768x32"]
  end

  config.vm.provider :hyperv do  |hv, override|
    hv.ip_address_timeout = 240
  end

end
