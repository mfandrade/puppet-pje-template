# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # FIXME: Descomente as duas linhas box e box_version a seguir OU
  # as linhas box e provision mais abaixo, conforme referências:
  # - https://github.com/mitchellh/vagrant/issues/6128#issuecomment-130122361
  # - http://stackoverflow.com/a/31820102
  config.vm.box = "puppetlabs/centos-6.6-32-puppet"
  config.vm.box_version = "1.0.1"

  #config.vm.box = "puppetlabs/centos-6.6-32-nocm"
  #config.vm.provision :shell, inline: <<-SHELL
  #  if [ ! -f repo-install ]; then
  #    RPM_REPO=https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
  #    sudo rpm -ivh $RPM_REPO && sudo touch repo-install;
  #  fi
  #  if [ ! -f puppet-install ]; then
  #    sudo yum install puppet -y && sudo touch puppet-install;
  #  fi
  #SHELL

  if Vagrant.has_plugin?('vagrant-proxyconf')
    if ENV['http_proxy']
      config.proxy.http = ENV['http_proxy']
    end
    if ENV['https_proxy']
      config.proxy.https = ENV['https_proxy']
    end
  end

  config.vm.boot_timeout = 600

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 8080, host: 8888

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  #config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network"

  #config.vm.hostname = "pje8-jb-int-z.trt8.net"
  config.vm.hostname = "pje8-jb-inta.trt8.net"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # View the documentation for the provider you are using for more
  # information on available options.
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "2048"
    vb.name = "PJE JBoss Template"
  end

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules/"
    puppet.manifest_file = "site.pp"
    puppet.manifests_path = "."
    #puppet.options = "--verbose --environment bugfix"
    puppet.options = "--verbose -debug"
  end
end
