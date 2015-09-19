class openshift3 ($deployment_type = "origin", $master = undef, $node_labels = {}, $openshift_dns_bind_addr = undef, $package_version = undef, $ssh_key = undef) {

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'
    $component_images = "${component_prefix}-\${component}:\${version}"
  } else {
    $component_prefix = 'openshift/origin'
    $component_images = "${component_prefix}-\${component}:\${version}"
  }

  $versionrel = split($package_version, '-')
  $version = $versionrel[0]
}
