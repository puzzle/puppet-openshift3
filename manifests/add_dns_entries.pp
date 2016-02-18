define openshift3::add_dns_entries($host = $title) {
  dnsmasq::hostrecord { $host['name']:
    ip => $host['ip'],
  }
}
