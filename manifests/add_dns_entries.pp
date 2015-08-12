define openshift3::add_dns_entries($host = $title) {
  dnsmasq::hostrecord { $host['hostname']:
    ip => $host['ip'],
  }
}
