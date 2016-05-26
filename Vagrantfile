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

require 'yaml'
require 'net/ssh'

origin_data = YAML.load_file('vagrant/hiera/group/origin.yaml')
enterprise_data = YAML.load_file('vagrant/hiera/group/enterprise.yaml')

origin_masters = origin_data['openshift3::masters']
origin_nodes = origin_data['openshift3::nodes']
origin_nodes = [] if origin_nodes.nil?
origin_vms = origin_masters + origin_nodes

enterprise_masters = enterprise_data['openshift3::masters']
enterprise_nodes = enterprise_data['openshift3::nodes']
enterprise_nodes = [] if enterprise_nodes.nil?
enterprise_vms = enterprise_masters + enterprise_nodes

vms = origin_vms + enterprise_vms

if Vagrant::Util::Platform.windows?
  hostname=`hostname`.chomp
else
  hostname=`hostname -s`.chomp
end

vms.each do |vm|
  vmname = vm['name'].split('.', 2)
  
  vm['short_name' ] = vmname[0]
  vm['rhsm_system_name'] = "#{vmname[0]}-#{hostname}.#{vmname[1]}"
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
end

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = :host
  end

  if config.user.has_key?('registration') and config.user['registration'].has_key?('subscription_pool')
    subscription_pool = config.user.registration.subscription_pool
  end
  if config.user.has_key?('provision') and config.user['provision'].has_key?('shell')
    user_shell_provision = config.user.provision.shell
  end
  if config.user.has_key?('config') and config.user['config'].has_key?('synced_folder_type')
    @synced_folder_type = config.user.config.synced_folder_type
  end

  config.vm.provision "shell", inline: <<-SHELL
    if [ -x /usr/bin/subscription-manager ] && [ ! -e /.subscribed ]; then
      subscription-manager remove --all
      subscription-manager attach --pool="#{subscription_pool}"
      subscription-manager repos --disable="*"
      subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-optional-rpms"
      touch /.subscribed
    fi

    yum install -y deltarpm git

    yum update -y

    rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    test -e /usr/bin/puppet || yum install -y puppet

    gem list --local | grep -q ^librarian-puppet || gem install librarian-puppet
    cd /vagrant && /usr/local/bin/librarian-puppet install --path /etc/puppet/librarian-modules

    cp -r /vagrant/.ssh /root
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
    chmod -R og-rwx /root/.ssh

    #{user_shell_provision}
  SHELL

  # libvirt provider memory and cpu configuration
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 4096
    libvirt.cpus = 4
    libvirt.storage_pool_name = config.user.libvirt.storage_pool_name if config.user.has_key?('libvirt') and config.user['libvirt'].has_key?('storage_pool_name')
    libvirt.suspend_mode = 'managedsave'
  end

  # virtualbox provider memory and cpu configuration
  config.vm.provider :virtualbox do |vbox|
    vbox.memory = 4096
    vbox.cpus = 4
  end

  enterprise_vms.each do |vm|
    config.vm.define vm['short_name'] do |vmconfig|
      vmconfig.vm.box = 'rhel72'

      vmconfig.registration.skip = false
      vmconfig.registration.name = vm['rhsm_system_name']
      vmconfig.registration.username = config.user.registration.subscriber_username if config.user.has_key?('registration')
      vmconfig.registration.password = config.user.registration.subscriber_password if config.user.has_key?('registration')
      vmconfig.registration.auto_attach = false

      vmconfig.vm.hostname = vm['name']
      vmconfig.vm.network :private_network, :ip => vm['ip']

      config.vm.provision :puppet do |puppet|
        puppet.synced_folder_type = @synced_folder_type unless @synced_folder_type.nil?
        puppet.manifests_path = "vagrant/manifests"
        puppet.manifest_file = "site.pp"
        puppet.hiera_config_path = "vagrant/hiera.yaml"
        puppet.working_directory = "/tmp/vagrant-puppet"
        puppet.options = "--verbose --modulepath=/etc/puppet/librarian-modules:/etc/puppet/modules"
        puppet.facter = {
          "vagrant" => "1",
          "hostgroup" => "enterprise",
          "openshift_hosts" => enterprise_vms.to_json
        }
      end
    end
  end

  origin_vms.each do |vm|
    config.vm.define vm['short_name'] do |vmconfig|
      vmconfig.vm.box = 'centos/7'

      vmconfig.registration.skip = true

      vmconfig.vm.hostname = vm['name']
      vmconfig.vm.network :private_network, :ip => vm['ip']

      config.vm.provision :puppet do |puppet|
        puppet.synced_folder_type = @synced_folder_type unless @synced_folder_type.nil?
        puppet.manifests_path = "vagrant/manifests"
        puppet.manifest_file = "site.pp"
        puppet.hiera_config_path = "vagrant/hiera.yaml"
        puppet.working_directory = "/tmp/vagrant-puppet"
        puppet.options = "--verbose --modulepath=/etc/puppet/librarian-modules:/etc/puppet/modules"
        puppet.facter = {
          "vagrant" => "1",
          "hostgroup" => "origin",
          "openshift_hosts" => origin_vms.to_json
        }
      end
    end 
  end

  if @synced_folder_type.nil?
    config.vm.synced_folder ".", "/vagrant"
    config.vm.synced_folder ".", "/etc/puppet/modules/openshift3"
  else
    config.vm.synced_folder ".", "/vagrant", type: @synced_folder_type
    config.vm.synced_folder ".", "/etc/puppet/modules/openshift3", type: @synced_folder_type
  end

end
