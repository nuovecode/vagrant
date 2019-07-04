# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
SITE_URL = "www.magento2.develop"
LANDRUSH_HOST = "magento2.develop"
LANDRUSH_TLD = "develop"
VM_NAME = "magento2-vagrant"
DB_DUMP_FILENAME = "prod_coop_db_anonimo.sql"
#IP_ADDRESS = "10.11.12.13"

REQUIRED_PLUGINS = %w(landrush vagrant-bindfs)

plugins_to_install = REQUIRED_PLUGINS.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Virtual Machine

  config.vm.box = "bitbull/magento-base"
  config.vm.box_version = "2.0.0"
  config.vm.hostname = SITE_URL
  #config.vm.network :private_network, ip: IP_ADDRESS

  # Bindfs

  config.bindfs.bind_folder "/vagrant", "/var/www/html", after: :provision
  config.bindfs.default_options = {
    force_user:   'vagrant',
    force_group:  'www-data',
    perms:        'u=rwX:g=rwD:o=rD'
  }

  # copy composer auth to VM

  config.vm.provision "shell", inline: "mkdir -p /home/vagrant/.composer"
  config.vm.provision "file", source: "~/.composer/auth.json", destination: "/tmp/composer_auth.json"
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "/tmp/id_rsa"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"

  # launch various commands including composer global install and magento setup

  config.vm.provision :shell, :path => "provision-vagrant.sh", :args => [SITE_URL, DB_DUMP_FILENAME]
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.name = VM_NAME
    #vb.gui = true
  end

  # Landrush

  if Vagrant.has_plugin? 'landrush'
    config.landrush.enable
    config.landrush.tld = LANDRUSH_TLD
    config.landrush.host LANDRUSH_HOST
    #config.landrush.guest_redirect_dns = false
  end

  # SSH

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.forward_agent = true


end


