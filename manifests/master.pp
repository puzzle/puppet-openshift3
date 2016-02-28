class openshift3::master {
  class { 'openshift3': } ->
  class { 'openshift3::repo': } ->
  class { 'openshift3::package': } ->
  class { 'openshift3::vagrant-master': } ->
  class { 'openshift3::ansible': } ->
  class { 'openshift3::upgrade-master': } ->
  class { 'openshift3::proxy-master': } ->
  class { 'openshift3::router': } ->
  class { 'openshift3::registry': } ->
  class { 'openshift3::metrics': } ->
  class { 'openshift3::logging': } ->
  class { 'openshift3::service-master': }
}
