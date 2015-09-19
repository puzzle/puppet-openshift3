# puppet-openshift3
Puppet Module to install and manage OpenShift Enterprise 3 and OpenShift Origin M5.

Work in progress!

## Features

  * Install OpenShift Enterprise, currently 3.0.0 and 3.0.1 or OpenShift Origin M5, currently 1.0.3 and 1.0.4
    * Optionally install and configure Dnsmasq DNS server for resolving application domains (useful in Vagrant VMs)
    * Install OpenShift prerequisites
    * Install and configure Ansible
    * Install OpenShift master and node with Ansible playbook provided by OpenShift
    * Download OpenShift component docker images
    * Install required router
    * Install required internal Docker registry
    * Configure test users when running in Vagrant, matching the ones in used in https://github.com/openshift/training
  * Upgrade OpenShift Enterprise, currently 3.0.0 to 3.0.1
  * Upgrade OpenShift Origin, currently 1.0.3 to 1.0.4

## Todo

   * Improve this README.
   * Implement upgrade of ImageStream images.

## Vagrant
If you have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed you can get a
virtual machine with a fully operational OpenShift Origin M5 master and node by running:

    vagrant up origin-master

Installing OpenShift inside the VM will take several minutes, depending on the speed of your machine and your
internet connection.
If you then point the resolver of your host machine to the IP address of the newly created virtual machine 
(172.22.22.22) you will be able to resolve the OpenShift Master and any deployed application by name,
provided the applications use one of the preconfigured domains (*.cloudapps.example.com, *.openshiftapps.com).
Please refer to this documentation for instructions on how to change the resolver on various operation systems,
but remember to use the IP address of the created virtual machine (172.22.22.22):
https://developers.google.com/speed/public-dns/docs/using.
The OpenShift Web Console is now available under https://origin-master.example.com:8443/.

## License
Copyright © 2015 Puzzle ITC GmbH

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
