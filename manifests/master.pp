class openshift3::master {
  class { 'openshift3': } ->
  class { 'openshift3::package': } ->
  class { 'openshift3::network': } ->
  class { 'openshift3::ansible': } ->
  class { 'openshift3::upgrade': } ->
  class { 'openshift3::docker-images': } ->
  class { 'openshift3::router': } ->
  class { 'openshift3::registry': } ->
  class { 'openshift3::user': }

  if $::vagrant {    
    class { 'openshift3::dns':
      require => Class['openshift3::network'],
      before => Class ['openshift3::ansible'],
    }
  }
}
