class openshift3::params {
  $deployment_type = "origin"
  $master = undef
  $node_labels = {
    'region' => 'primary',
    'zone' => 'default',
  }
  $app_domain = 'cloudapps.example.com'
  $openshift_dns_bind_addr = undef
  $package_version = undef
  $ssh_key = undef
}
