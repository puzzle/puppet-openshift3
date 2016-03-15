class openshift3 (
  $deployment_type = $::openshift3::params::deployment_type,
  $identity_providers = $::openshift3::params::identity_providers,
  $ldap_ca_crt = undef,
  $masters,
  $nodes = [],
  $etcd = [],
  $lb = [],
  $app_domain = $::openshift3::params::app_domain,
  $openshift_dns_bind_addr = undef,
  $version = undef,
  $cluster_network_cidr = $::openshift3::params::cluster_network_cidr,
  $configure_epel = $::openshift3::params::configure_epel,
  $epel_repo_id = $::openshift3::params::epel_repo_id,
  $http_proxy = undef,
  $https_proxy = undef,
  $no_proxy = $::openshift3::params::no_proxy,
  $install_router = $::openshift3::params::install_router,
  $failover_router_replicas = undef,
  $failover_router_ips = undef,
  $failover_router_label = undef,
  $install_registry = $::openshift3::params::install_registry,
  $metrics_use_persistent_storage = $::openshift3::params::metrics_use_persistent_storage,
  $metrics_ssl_cert = undef,
  $metrics_ssl_key = undef,
  $metrics_ca_cert = undef,
  $metrics_image_version = $::openshift3::params::metrics_image_version,
  $es_instance_ram = $::openshift3::params::es_instance_ram,
  $es_ops_instance_ram = $::openshift3::params::es_ops_instance_ram,
  $enable_ops_logging = $::openshift3::params::enable_ops_logging,
  $logging_image_version = $::openshift3::params::logging_image_version,
  $master_cluster_method = undef,
  $master_cluster_hostname = undef,
  $master_cluster_public_hostname = undef,
  $master_public_api_url = undef,
  $master_public_console_url = undef,
  $master_style_repo_url = undef,
  $master_style_repo_ref = $::openshift3::params::master_style_repo_ref,
  $master_style_repo_ssh_key = undef,
  $master_extension_scripts = undef,
  $master_extension_stylesheets = undef,
  $master_extensions = undef,
  $master_oauth_template = undef,
  $ansible_ssh_user = $::openshift3::params::ansible_ssh_user,
  $ansible_sudo = $::openshift3::params::ansible_sudo,
  $set_node_ip = $::openshift3::params::set_node_ip,
  $registry_ip = $::openshift3::params::registry_ip,
  $sdn_network_plugin_name = undef,
  $docker_options = $::openshift3::params::docker_options,
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

  if $master_style_repo_url {
    if $master_extension_stylesheets {
      $real_master_extension_stylesheets = prefix($master_extension_stylesheets, '/var/lib/puppet-openshift3/style/')
    }
    if $master_extension_scripts {
      $real_master_extension_scripts = prefix($master_extension_scripts, '/var/lib/puppet-openshift3/style/')
    }
    if $master_extensions {
      $real_master_extension = prefix($master_extensions, '/var/lib/puppet-openshift3/style/')
    }
    if $master_oauth_template {
      $real_master_oauth_template = "/var/lib/puppet-openshift3/style/${master_oauth_template}"
    }
  }

  ensure_resource('file', '/var/lib/puppet-openshift3', { ensure => directory })
  ensure_resource('file', '/var/lib/puppet-openshift3/certs', { ensure => directory })
}
