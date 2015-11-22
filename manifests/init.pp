class openshift3 (
  $deployment_type = $::openshift3::params::deployment_type,
  $identity_providers = $::openshift3::params::identity_providers,
  $master = $::openshift3::params::master,
  $node_labels = $::openshift3::params::node_labels,
  $app_domain = $::openshift3::params::app_domain,
  $openshift_dns_bind_addr = undef,
  $version = undef,
  $ssh_key = undef,
  $cluster_network_cidr = $::openshift3::params::cluster_network_cidr,
) inherits ::openshift3::params {

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'
    $package_name = 'openshift'
    if versioncmp($version, '3.1.0') >= 0 {
      $docker_version = '1.8.2'
    } else {
      $docker_version = '1.6.2'
    }
  } else {
    $component_prefix = 'openshift/origin'
    if versioncmp($version, '1.0.5') > 0 {
      $package_name = 'origin'
      $docker_version = '1.8.2'
    } else {
      $package_name = 'openshift'
      $docker_version = '1.6.2'
    }
  }
  $component_images = "${component_prefix}-\${component}:\${version}"
}
