class openshift3::node {
  class { 'openshift3': } ->
  class { 'openshift3::package': } ->
  class { 'openshift3::network': } ->
  class { 'openshift3::ssh-keys': } ->
  class { 'openshift3::ansible': } ->
  class { 'openshift3::upgrade-node': } ->
  class { 'openshift3::docker-images': }
}
