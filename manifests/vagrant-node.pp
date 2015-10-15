class openshift3::vagrant-node {

  if $::vagrant {
    $openshift_hosts = parsejson($::openshift_hosts)
    $master_ip = $openshift_hosts[0]['ip']

    file { '/etc/hosts':
      ensure  => present,
       owner  => 'root',
      group  => 'root',
      mode   => 0644,
      content => template("openshift3/etc/hosts.erb"),
    }

    class { 'resolv_conf':
      domainname => '.',
      nameservers => [$master_ip, '8.8.8.8', '8.8.4.4'],  # Use Google Public DNS as forwarder
    }

    # Prevent dhclient from overwriting puppet managed /etc/resolv.conf with DHCP provided DNS servers
#    augeas { "/etc/sysconfig/network-scripts/ifcfg-${::network_primary_interface}":
#      changes => [
#        "set /files/etc/sysconfig/network-scripts/ifcfg-${::network_primary_interface}/PEERDNS no",
#      ],
#    }
 
    file { '/root/.ssh':
      ensure  => directory,
      owner  => 'root',
      group  => 'root',
      mode   => 0700,
    }

    file { '/root/.ssh/id_rsa.pub':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      source => '/vagrant/.ssh/id_rsa.pub',
    }

    file { '/root/.ssh/id_rsa':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      source => '/vagrant/.ssh/id_rsa',
    }

    ssh_authorized_key { "${::openshift3::ssh_key[name]}":
      user => 'root',
      type => $::openshift3::ssh_key[type],
      key  => $::openshift3::ssh_key[key],
    }
  }
}
