class openshift3::params {
  $deployment_type = "origin"
  $identity_providers = {
    'name' => 'htpasswd_auth',
    'login' => 'true',
    'challenge' => 'true',
    'kind' => 'HTPasswdPasswordIdentityProvider',
    'filename' => '/etc/openshift/openshift-passwd',
  }
  $master = undef
  $node_labels = {
    'region' => 'primary',
    'zone' => 'default',
  }
  $openshift_dns_bind_addr = undef
  $package_version = undef
  $ssh_key = undef
}
