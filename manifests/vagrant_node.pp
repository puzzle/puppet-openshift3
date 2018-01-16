class openshift3::vagrant_node {

  if $::vagrant {
    $openshift_hosts = parsejson($::openshift_hosts)
    $master_ip = $openshift_hosts[0]['ip']

    class { '::ntp':
      servers => [ '0.rhel.pool.ntp.org', '1.rhel.pool.ntp.org', '2.rhel.pool.ntp.org' ],
    }

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
    augeas { "/etc/sysconfig/network-scripts/ifcfg-${::network_primary_interface}":
      changes => [
        "set /files/etc/sysconfig/network-scripts/ifcfg-${::network_primary_interface}/PEERDNS no",
      ],
    }
  }
}
