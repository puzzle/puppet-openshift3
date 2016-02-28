class openshift3 (
  $deployment_type = $::openshift3::params::deployment_type,
  $identity_providers = $::openshift3::params::identity_providers,
  $masters,
  $nodes = [],
  $etcd = [],
  $lb = [],
  $app_domain = $::openshift3::params::app_domain,
  $openshift_dns_bind_addr = undef,
  $version = undef,
  $cluster_network_cidr = $::openshift3::params::cluster_network_cidr,
  $configure_epel = $::openshift3::params::configure_epel,
  $http_proxy = undef,
  $https_proxy = undef,
  $no_proxy = $::openshift3::params::no_proxy,
  $install_router = $::openshift3::params::install_router,
  $install_registry = $::openshift3::params::install_registry,
  $metrics_ssl_cert = undef,
  $metrics_ssl_key = undef,
  $metrics_ca_cert = undef,
  $enable_ops_logging = $::openshift3::params::enable_ops_logging,
  $master_cluster_method = $::openshift3::params::master_cluster_method,
  $ansible_ssh_user = $::openshift3::params::ansible_ssh_user,
  $ansible_sudo = $::openshift3::params::ansible_sudo,
  $set_node_ip = $::openshift3::params::set_node_ip,
  $registry_ip = $::openshift3::params::registry_ip,
  $sdn_network_plugin_name = undef,
) inherits ::openshift3::params {
 
  $master = $masters[0]['name']
  $master_ip = $masters[0]['ip']

  $version_array = split($version, '\.')
  $major = $version_array[0]
  $minor = $version_array[1]

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'

    if versioncmp($version, '3.1.0') >= 0 {
      $real_deployment_type = 'openshift-enterprise'
      $package_name = 'atomic-openshift'
      $conf_dir = '/etc/origin'
      $docker_version = '1.8.2'
    } else {
      $real_deployment_type = 'enterprise'
      $package_name = 'openshift'
      $conf_dir = '/etc/openshift'
      $docker_version = '1.6.2'
    }
  } else {
    $real_deployment_type = 'origin'
    $component_prefix = 'openshift/origin'
    $conf_dir = '/etc/origin'
    if versioncmp($version, '1.0.5') > 0 {
      $package_name = 'origin'
      $docker_version = '1.8.2'
    } else {
      $package_name = 'openshift'
      $docker_version = '1.6.2'
    }
  }
  $component_images = "${component_prefix}-\${component}:\${version}"

  if $internal_hostname {
    $hostname = $internal_hostname
  } else {
    $hostname = $::fqdn
  }

  ensure_resource('file', '/var/lib/puppet-openshift3', { ensure => directory })
  ensure_resource('file', '/var/lib/puppet-openshift3/certs', { ensure => directory })
}
