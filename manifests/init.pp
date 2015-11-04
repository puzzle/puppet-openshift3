class openshift3 (
  $deployment_type = $::openshift3::params::deployment_type,
  $identity_providers = '',
  $master = $::openshift3::params::master,
  $node_labels = $::openshift3::params::node_labels,
  $app_domain = $::openshift3::params::app_domain,
  $openshift_dns_bind_addr = undef,
  $package_version = undef,
  $ssh_key = undef,
  $internal_ip = undef,
  $internal_hostname = undef,
) inherits ::openshift3::params {

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'
    $package_prefix = 'enterprise'
  } else {
    $component_prefix = 'openshift/origin'
    $package_prefix = 'origin'
  }
  $component_images = "${component_prefix}-\${component}:\${version}"

  $versionrel = split($package_version, '-')
  $version = $versionrel[0]

  if ($identity_providers == '') {
    $identity_providers_final = [{
      'name' => 'htpasswd_auth',
      'login' => 'true',
      'challenge' => 'true',
      'kind' => 'HTPasswdPasswordIdentityProvider',
      'filename' => "/etc/${package_prefix}/openshift-passwd",
    }]
  } else {
    $identity_providers_final = $identity_providers
  }
}
