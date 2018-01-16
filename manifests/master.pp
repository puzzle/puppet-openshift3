class openshift3::master {
  class { 'openshift3': } ->
  class { 'openshift3::repo': } ->
  class { 'openshift3::package': } ->
  class { 'openshift3::vagrant_master': } ->
  class { 'openshift3::ansible': } ->
  class { 'openshift3::router': } ->
  class { 'openshift3::failover_routers': } ->
  class { 'openshift3::registry': } ->
  class { 'openshift3::metrics': } ->
  class { 'openshift3::logging': } ->
  class { 'openshift3::monitoring': }
}
