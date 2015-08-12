class openshift3::node {
  include ::openshift3

  file { '/root/.ssh':
    ensure  => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0700,
  }

  if $::vagrant {
    $ose_hosts = parsejson($::ose_hosts)
    $master_ip = $ose_hosts[0]['ip']

    file { '/root/.ssh/id_rsa':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      source => '/vagrant/.ssh/id_rsa',
    }

    file { '/root/.ssh/id_rsa.pub':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      source => '/vagrant/.ssh/id_rsa.pub',
    }


    if defined(Service['dnsmasq']) {
      $resolv_require = [ Service['dnsmasq'] ]
    } else {
      $resolv_require = []
    }

    class { 'resolv_conf':
      domainname => '.',
      nameservers => [$master_ip, '8.8.8.8', '8.8.4.4'],  # Use Google Public DNS as forwarder
      require => $resolv_require,
    }
  }
}
