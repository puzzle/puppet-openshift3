class openshift3::params {
  $deployment_type = "origin"
  $identity_providers = [{
    'name' => 'htpasswd_auth',
    'login' => 'true',
    'challenge' => 'true',
    'kind' => 'HTPasswdPasswordIdentityProvider',
    'filename' => '/etc/openshift/openshift-passwd',
  }]
  $master = undef
  $node_labels = {
    'region' => 'primary',
    'zone' => 'default',
  }
  $app_domain = 'cloudapps.example.com'
  $openshift_dns_bind_addr = undef
  $package_version = undef
  $ssh_key = undef
  $cluster_network_cidr = '10.1.0.0/16'
  $schedulable = true
}
