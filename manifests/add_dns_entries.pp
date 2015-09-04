define openshift3::add_dns_entries($vmconfig) {
  dnsmasq::hostrecord { "${title}.${::domain}":
    ip => $vmconfig[$title]['ip'],
  }
}
