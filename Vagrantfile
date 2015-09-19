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

require 'json'
require 'yaml'
require 'net/ssh'

domain = "example.com"

# First host must be the master
ose_hosts = [
  { :name => "ose3-master", :ip => "172.22.22.122" },
  { :name => "ose3-node1", :ip => "172.22.22.123" },
  { :name => "ose3-node2", :ip => "172.22.22.124" },
]
origin_hosts = [
  { :name => "origin-master", :ip => "172.22.22.22" },
  { :name => "origin-node1", :ip => "172.22.22.23" },
  { :name => "origin-node2", :ip => "172.22.22.24" },
]
hosts = ose_hosts + origin_hosts

hostname=`hostname -s`.chomp
hosts.each do |host|
  host[:hostname] = "#{host[:name]}.#{domain}"
  host[:rhsm_system_name] = "#{host[:name]}-#{hostname}.#{domain}"
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

  ose_hosts.each do |host|
    config.vm.define host[:name] do |vmconfig|
      vmconfig.vm.box = 'rhel71'

      vmconfig.registration.name = host[:rhsm_system_name]
      vmconfig.registration.username = config.user.registration.subscriber_username if config.user.has_key?('registration')
      vmconfig.registration.password = config.user.registration.subscriber_password if config.user.has_key?('registration')
      vmconfig.registration.auto_attach = false

      vmconfig.vm.hostname = host[:hostname]
      vmconfig.vm.network :private_network, :ip => host[:ip]

      config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "vagrant/manifests"
        puppet.manifest_file = "site.pp"
        puppet.hiera_config_path = "vagrant/hiera.yaml"
        puppet.working_directory = "/tmp/vagrant-puppet"
        puppet.options = "--verbose --modulepath=/etc/puppet/librarian-modules:/etc/puppet/modules"
        puppet.facter = {
          "vagrant" => "1",
          "vagrant_ip" => host[:ip],
          "hostgroup" => "enterprise",
          "openshift_hosts" => ose_hosts.to_json,
        }
      end
    end
  end

  origin_hosts.each do |host|
    config.vm.define host[:name] do |vmconfig|
      vmconfig.vm.box = 'boxcutter/centos71'

      vmconfig.registration.skip = true

      vmconfig.vm.hostname = host[:hostname]
      vmconfig.vm.network :private_network, :ip => host[:ip]

      config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "vagrant/manifests"
        puppet.manifest_file = "site.pp"
        puppet.hiera_config_path = "vagrant/hiera.yaml"
        puppet.working_directory = "/tmp/vagrant-puppet"
        puppet.options = "--verbose --modulepath=/etc/puppet/librarian-modules:/etc/puppet/modules"
        puppet.facter = {
          "vagrant" => "1",
          "vagrant_ip" => host[:ip],
          "hostgroup" => "origin",
          "openshift_hosts" => origin_hosts.to_json,
        }
      end
    end 
  end

  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder ".", "/etc/puppet/modules/openshift3"

end
