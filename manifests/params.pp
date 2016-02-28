class openshift3::params {
  $deployment_type = "origin"
  $identity_providers = [{
    'name' => 'htpasswd_auth',
    'login' => 'true',
    'challenge' => 'true',
    'kind' => 'HTPasswdPasswordIdentityProvider',
    'filename' => '/etc/openshift/openshift-passwd',
  }]
  $app_domain = 'cloudapps.example.com'
  $openshift_dns_bind_addr = undef
  $package_version = undef
  $cluster_network_cidr = '10.1.0.0/16'
  $configure_epel = true
  $no_proxy = "localhost,127.0.0.1"
  $install_router = true
  $install_registry = true
  $enable_ops_logging = false
  $master_cluster_method = 'native'
  $ansible_ssh_user = 'root'
  $ansible_sudo = false
  $set_node_ip = false
}
