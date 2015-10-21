class openshift3 (
  $deployment_type = $::openshift3::params::deployment_type,
  $identity_providers = $::openshift3::params::identity_providers,
  $master = $::openshift3::params::master,
  $node_labels = $::openshift3::params::node_labels,
  $app_domain = $::openshift3::params::app_domain,
  $openshift_dns_bind_addr = undef,
  $package_version = undef,
  $ssh_key = undef,
  $cluster_network_cidr = $::openshift3::params::cluster_network_cidr,
) inherits ::openshift3::params {

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'
  } else {
    $component_prefix = 'openshift/origin'
  }
  $component_images = "${component_prefix}-\${component}:\${version}"

  $versionrel = split($package_version, '-')
  $version = $versionrel[0]
}
