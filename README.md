# puppet-openshift3

#### Table of Contents

1. [Description](#description)
  * [Features](#features)
2. [Setup OpenShift V3](#setup-openshift-v3)
  * [What openshift3 affects](#what-openshift3-affects)
  * [Setup Requirements](#setup-requirements)
    * [SSH Keys](#ssh-keys)
    * [OpenShift Enterprise](#openshift-enterprise)
    * [OpenShift Origin](#openshift-origin)
  * [Beginning with openshift3](#beginning-with-openshift3)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
7. [Release Notes/Contributors/Etc. **Optional**](#release-notescontributorsetc-optional)
8. [Vagrant](#vagrant)
  * [OpenShift Origin](#openshift-origin-1)
  * [OpenShift Enterprise](#openshift-enterprise-1)
9. [License](#license)

## Description

Puppet Module to install and manage OpenShift Enterprise 3 and OpenShift Origin M5 on RHEL/CentOS 7.1 or later. This module has been tested with
Puppet 3.8.x.

Work in progress!

### Features

  * Install OpenShift Enterprise, currently 3.0.0, 3.0.1 and 3.0.2 or OpenShift Origin M5, currently 1.0.6, 1.0.7 and 1.0.8
    * Optionally install and configure Dnsmasq DNS server for resolving application domains (useful in Vagrant VMs)
    * Install OpenShift prerequisites
    * Install and configure Ansible
    * Install OpenShift master and node with Ansible playbook provided by OpenShift
    * Download OpenShift component docker images
    * Install required router
    * Install required internal Docker registry
    * Configure test users when running in Vagrant, matching the ones in used in https://github.com/openshift/training
  * Upgrade OpenShift Enterprise
  * Upgrade OpenShift Origin

## Setup OpenShift V3

### What openshift3 affects

This module make the following changes to the systems it runs on, mostly as per OpenShift requirements:
  * Disables NetworkManager service
  * Disables firewalld service
  * Reconfigures the iptables firewall
  * Reconfigures SELinux
  * Adds EPEL repository
  * Changes active yum/Subscription Manager repositories
  * Installs and reconfigures Ansible
  * Installs and starts OpenShift
  * Installs, reconfigures and starts Docker
  * Pulls OpenShift Docker images

It is highly recommended to use dedicated hosts for OpenShift masters and nodes.

### Setup Requirements

#### SSH Keys
SSH keys need to be exchanged and SSH needs to be configured in such a way that:
  1. The master can login to all nodes as root without password
  2. All nodes can login to the master as root without password

The reason for requirement 2 is that currently the openshift3 module calls Ansible on each host and the OpenShift Ansible playbook always needs to access the master.
It's planed that a future version of the module brings the necessary improvements to drop requirement 2.

#### OpenShift Enterprise
To install OpenShift Enterprise your system needs to be correctly registered and have a suitable OpenShift Enterprise subscription attached.
This module automatically enables the required package repositories. Please note that OpenShift Enterprise 3 can only be installed on Red Hat Enterprise Linux (RHEL) 7.1
or later. Newer versions of OpenShift Enterprise 3.x may require newer versions of RHEL. Please check the "Prerequisites"
section of the "Installation and Configuration" guide of the version you want to install.

#### OpenShift Origin
Installation of OpenShift Origin has been tested on CentOS 7.1 and Red Hat Enterprise Linux (RHEL) 7.1. To install OpenShift Origin on RHEL your system
needs to be correctly registered and have a suitable RHEL subscription attached. This module automatically enables the required package repositories.

### Beginning with openshift3

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

    class { 'openshift3':
      deployment_type => 'enterprise',               # or 'origin', which is also the default
      master          => 'ose3-master.example.com',  # public FQDN of your OpenShift 3 master
      version         => '3.1.0.4',                  # OpenShift version to install
    }

## Usage

This section is where you describe how to customize, configure, and do the fancy stuff with your module here. It's especially helpful if you include usage examples and code samples for doing things with your module.

## Reference

Here, include a complete list of your module's classes, types, providers, facts, along with the parameters for each. Users refer to this section (thus the name "Reference") to find specific details; most users don't read it per se.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there are Known Issues, you might want to include them under their own heading here.

## Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header. 


## Vagrant
If you have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed you can get a
virtual machine with a fully operational OpenShift instance.

### OpenShift Origin
Create OpenShift Origin M5 master and node by running:

    vagrant up origin-master

Installing OpenShift inside the VM will take several minutes, depending on the speed of your machine and your
internet connection.
If you then point the resolver of your host machine to the IP address of the newly created virtual machine 
(172.22.22.22) you will be able to resolve the OpenShift Master and any deployed application by name,
provided the applications use one of the preconfigured domains (*.cloudapps.example.com, *.openshiftapps.com).
Please refer to this documentation for instructions on how to change the resolver on various operation systems,
but remember to use the IP address of the created virtual machine (172.22.22.22):
https://developers.google.com/speed/public-dns/docs/using.

The OpenShift Web Console is now available under https://origin-master.example.com:8443/

### OpenShift Enterprise
You need to have a RHEL 7.2 Vagrant box available.
Copy the vagrantuser.example file to .vagrantuser and fill in your RedHat data.

Create OpenShift Enterprise master by running:

    vagrant up ose3-master

The IP address differs to the Origin installation. Use 172.22.22.122 instead of 172.22.22.22.

The OpenShift Web Console is now available under https://ose3-master.example.com:8443/

## License
Copyright © 2016 Puzzle ITC GmbH

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
