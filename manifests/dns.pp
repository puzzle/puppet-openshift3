class openshift3::dns {
  $ose_hosts = parsejson($::ose_hosts)
  $master_ip = $ose_hosts[0]['ip']

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
    ip => $::network_primary_ip,
  }
  dnsmasq::address { ".openshiftapps.com":
    ip => $::network_primary_ip,
  }

  openshift3::add_dns_entries { $ose_hosts: }
}
