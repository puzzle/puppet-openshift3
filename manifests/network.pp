class openshift3::network {
  service { 'NetworkManager':
   ensure => stopped,
   enable => false,
  } ->

  service { 'network':
    ensure => running,
    enable => true,
  }
}
