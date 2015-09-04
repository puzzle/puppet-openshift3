class openshift3::dns {
  if $::vagrant {
    $master_values = values($::openshift3::masters)
    $master_ip = $master_values[0]['ip']

#    $ose_hosts = parsejson($::ose_hosts)
#    $master_ip = $ose_hosts[0]['ip']

    firewall { '500 Allow UDP DNS requests':
      action => 'accept',
      state  => 'NEW',
      dport  => [53],
      proto  => 'udp',
    }

    firewall { '501 Allow TCP DNS requests':
      action => 'accept',
      state  => 'NEW',
      dport  => [53],
      proto  => 'tcp',
    }

    class { 'dnsmasq':
      no_hosts => true,
      listen_address => [$master_ip]
    }

    file { '/etc/dnsmasq.d/dnsmasq-extra.conf':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      content => template("openshift3/etc/dnsmasq-extra.conf.erb"),
      notify => Service['dnsmasq'],
    }

    # Add wildcard entries for OpenShift 3 apps
    dnsmasq::address { ".cloudapps.$::domain":
      ip => $master_ip,
    }
    dnsmasq::address { ".openshiftapps.com":
      ip => $master_ip,
    }

#    $hosts = concat(values($::openshift3::masters), values($::openshift3::nodes))
#    notice($hosts)

    $master_keys = keys($::openshift3::masters)
    openshift3::add_dns_entries { $master_keys:
      vmconfig => $::openshift3::masters
    }

    $node_keys = keys($::openshift3::nodes)
    openshift3::add_dns_entries { $node_keys:
      vmconfig => $::openshift3::nodes
    }

#    create_resources(openshift3::add_dns_entries, $::openshift3::masters)
#    create_resources(openshift3::add_dns_entries, $::openshift3::nodes)
#    openshift3::add_dns_entries { values($::openshift3::nodes) }

    Service['dnsmasq'] -> Class['resolv_conf']
  }
}
