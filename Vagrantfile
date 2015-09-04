# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Puppet Module to install and manage OpenShift Enterprise 3 and OpenShift Origin M5.
# Copyright 2015 (C) Puzzle ITC GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

#require 'json'
require 'yaml'
require 'net/ssh'

origin_data = YAML.load_file('vagrant/hiera/product/origin.yaml')
enterprise_data = YAML.load_file('vagrant/hiera/product/enterprise.yaml')

origin_domain = origin_data['openshift3::domain']
enterprise_domain = enterprise_data['openshift3::domain']

origin_masters = origin_data['openshift3::masters']
origin_nodes = origin_data['openshift3::nodes']
origin_vms = origin_masters.merge(origin_nodes)

enterprise_masters = enterprise_data['openshift3::masters']
enterprise_nodes = enterprise_data['openshift3::nodes']
enterprise_vms = enterprise_masters.merge(enterprise_nodes)

vms = origin_vms.merge(enterprise_vms)

hostname=`hostname -s`.chomp
#vms.each do |vmname, vmdata|
#  vmdata[:fqdn] = "#{vmname}.#{domain}"
#  vmdata[:rhsm_system_name] = "#{vmname}-#{hostname}.#{domain}"
#end

# 1440956713,ose3-master,state,running
unless ARGV[0] == 'status'
  IO.popen("vagrant status --machine-readable") do |io|
    io.each_line do |line|
      (timestamp,host,key,value) = line.chomp.split(',')
      if key == 'state'
        vms[host][:running] = value == 'running'        
      end
    end
  end
end

# Generate ssh keys for nodes, used to synchronize certificates between master and nodes
if not File.exist?('.ssh/id_rsa')
  FileUtils.mkdir_p '.ssh', :mode => 0700

  key = OpenSSL::PKey::RSA.new 2048
  type = key.public_key.ssh_type
  data = [ key.public_key.to_blob ].pack('m0')
  ssh_key = { 'openshift3::ssh_key' => { 'name' => 'ose3', 'type' => type, 'key' => data } }

  File.open('.ssh/id_rsa', 'w', 0600) do |file|
    file.write key.to_pem
  end

  File.open('.ssh/id_rsa.pub', 'w', 0600) do |file|
    file.write "#{type} #{data}"
  end

  File.open('vagrant/hiera/ssh.yaml', 'w', 0600) do |file|
    file.write ssh_key.to_yaml
  end
end

Vagrant.configure(2) do |config|  
  if config.user.has_key?('registration') and config.user['registration'].has_key?('subscription_pool')
    subscription_pool = config.user.registration.subscription_pool
  end
  if config.user.has_key?('provision') and config.user['provision'].has_key?('shell')
    user_shell_provision = config.user.provision.shell
  end

  config.vm.provision "shell", inline: <<-SHELL
    if [ -x /usr/bin/subscription-manager ] && [ ! -e /.subscribed ]; then
      subscription-manager remove --all
      subscription-manager attach --pool="#{subscription_pool}"
      subscription-manager repos --disable="*"
      subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-optional-rpms" --enable="rhel-7-server-ose-3.0-rpms"

      touch /.subscribed
    fi

    yum install -y deltarpm git

    yum update -y

    rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    test -e /usr/bin/puppet || yum install -y puppet

    gem list --local | grep -q ^librarian-puppet || gem install librarian-puppet
    cd /vagrant && /usr/local/bin/librarian-puppet install --path /etc/puppet/librarian-modules

    #{user_shell_provision}
  SHELL

  config.vm.provider :virtualbox do |vbox|
    vbox.memory = 4096
    vbox.cpus = 4
  end

  enterprise_vms.each do |vmname, vmdata|
    config.vm.define vmname do |vmconfig|
      vmconfig.vm.box = 'rhel71'

      vmconfig.registration.skip = false
      vmconfig.registration.name = "#{vmname}-#{hostname}.#{enterprise_domain}"
      vmconfig.registration.username = config.user.registration.subscriber_username if config.user.has_key?('registration')
      vmconfig.registration.password = config.user.registration.subscriber_password if config.user.has_key?('registration')
      vmconfig.registration.auto_attach = false

      vmconfig.vm.hostname = "#{vmname}.#{enterprise_domain}"
      vmconfig.vm.network :private_network, :ip => vmdata['ip']

      config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "vagrant/manifests"
        puppet.manifest_file = "site.pp"
        puppet.hiera_config_path = "vagrant/hiera.yaml"
        puppet.working_directory = "/tmp/vagrant-puppet"
        puppet.options = "--verbose --modulepath=/etc/puppet/librarian-modules:/etc/puppet/modules"
        puppet.facter = {
          "vagrant" => "1",
          "openshift_product" => "enterprise",
        }
      end
    end
  end

  origin_vms.each do |vmname, vmdata|
    config.vm.define vmname do |vmconfig|
      vmconfig.vm.box = 'boxcutter/centos71'

      vmconfig.registration.skip = true

      vmconfig.vm.hostname = "#{vmname}.#{origin_domain}"
      vmconfig.vm.network :private_network, :ip => vmdata['ip']

      puts "#{vmname} #{vmdata['ip']}"

      config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "vagrant/manifests"
        puppet.manifest_file = "site.pp"
        puppet.hiera_config_path = "vagrant/hiera.yaml"
        puppet.working_directory = "/tmp/vagrant-puppet"
        puppet.options = "--verbose --modulepath=/etc/puppet/librarian-modules:/etc/puppet/modules"
        puppet.facter = {
          "vagrant" => "1",
          "openshift_product" => "origin",
        }
      end
    end 
  end

  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder ".", "/etc/puppet/modules/openshift3"

end
