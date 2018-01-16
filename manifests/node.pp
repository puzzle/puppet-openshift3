class openshift3::node {
  class { 'openshift3': } ->
  class { 'openshift3::repo': } ->
  class { 'openshift3::package': } ->
  class { 'openshift3::vagrant_node': } ->
  class { 'openshift3::network': } ->
  class { 'openshift3::ansible': } ->
  class { 'openshift3::proxy-node': } ->
  class { 'openshift3::docker': } ->
  class { 'openshift3::upgrade_node': } ->
  class { 'openshift3::docker_images': }
}
