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
  $router_image = undef,
  $registry_image = undef,
  $failover_router_replicas = undef,
  $failover_router_ips = undef,
  $failover_router_label = undef,
  $failover_router_image = undef,
  $failover_keepalived_image = undef,
  $install_registry = $::openshift3::params::install_registry,
  $registry_volume_size = undef,
  $install_metrics = ::openshift3::params::install_metrics,
  $metrics_use_persistent_storage = $::openshift3::params::metrics_use_persistent_storage,
  $metrics_ssl_cert = undef,
  $metrics_ssl_key = undef,
  $metrics_ca_cert = undef,
  $metrics_image_version = $::openshift3::params::metrics_image_version,
  $metrics_pv_size = $::openshift3::params::metrics_pv_size,
  $metrics_duration = $::openshift3::params::metrics_duration,
  $metrics_domain = undef,
  $install_logging = $::openshift3::params::install_logging,
  $es_instance_ram = $::openshift3::params::es_instance_ram,
  $es_ops_instance_ram = $::openshift3::params::es_ops_instance_ram,
  $enable_ops_logging = $::openshift3::params::enable_ops_logging,
  $logging_image_version = $::openshift3::params::logging_image_version,
  $logging_volume_size = undef,
  $logging_domain = undef,
  $logging_ops_domain = undef,
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
  $ansible_version = $::openshift3::params::ansible_version,
  $ansible_ssh_user = $::openshift3::params::ansible_ssh_user,
  $ansible_sudo = $::openshift3::params::ansible_sudo,
  $ansible_vars = [],
  $openshift_ansible_version = $::openshift3::params::openshift_ansible_version,
  $set_node_ip = $::openshift3::params::set_node_ip,
  $set_hostname = $::openshift3::params::set_hostname,
  $registry_ip = $::openshift3::params::registry_ip,
  $sdn_network_plugin_name = undef,
  $docker_version = undef,
  $docker_options = $::openshift3::params::docker_options,
  $project_request_template = $::openshift3::params::project_request_template,
  $quota_sync_period = $::openshift3::params::quota_sync_period,
) inherits ::openshift3::params {
 
  $master = $masters[0]['name']
  $master_ip = $masters[0]['ip']

  $version_array = split($version, '\.')
  $major = $version_array[0]
  $minor = $version_array[1]
  $patch = $version_array[2]

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'

    if versioncmp($version, '3.2.0') >= 0 {
      $real_deployment_type = 'openshift-enterprise'
      $package_name = 'atomic-openshift'
      $conf_dir = '/etc/origin'
      $default_docker_version = '1.9.1'
      $ansible_vars_default = {
        # openshift_use_dnsmasq => true,  Don't set this, which is the default value, because of a bug in the OpenShift playbook
      }
    } elsif versioncmp($version, '3.1.0') >= 0 {
      $real_deployment_type = 'openshift-enterprise'
      $package_name = 'atomic-openshift'
      $conf_dir = '/etc/origin'
      $default_docker_version = '1.8.2'
      $ansible_vars_default = {
        openshift_use_dnsmasq => false,
      }
    } else {
      $real_deployment_type = 'enterprise'
      $package_name = 'openshift'
      $conf_dir = '/etc/openshift'
      $default_docker_version = '1.6.2'
      $ansible_vars_default = {
        openshift_use_dnsmasq => false,
      }
    }
  } else {
    $real_deployment_type = 'origin'
    $component_prefix = 'openshift/origin'
    $conf_dir = '/etc/origin'
    if versioncmp($version, '1.0.5') > 0 {
      $package_name = 'origin'
      $default_docker_version = '1.8.2'
      $ansible_vars_default = {
        openshift_use_dnsmasq => false,
      }
    } else {
      $package_name = 'openshift'
      $default_docker_version = '1.6.2'
      $ansible_vars_default = {
        openshift_use_dnsmasq => false,
      }
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
      $real_master_extensions = prefix($master_extensions, '/var/lib/puppet-openshift3/style/')
    }
    if $master_oauth_template {
      $real_master_oauth_template = "/var/lib/puppet-openshift3/style/${master_oauth_template}"
    }
  }

  if $docker_version {
    $real_docker_version = $docker_version
  } else {
    $real_docker_version = $default_docker_version
  }

  $real_ansible_vars = merge($ansible_vars_default, $ansible_vars)

  ensure_resource('file', '/var/lib/puppet-openshift3', { ensure => directory })
  ensure_resource('file', '/var/lib/puppet-openshift3/certs', { ensure => directory })
}
