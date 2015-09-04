class openshift3 ($domain, $masters, $nodes, $deployment_type = "origin", $package_version = undef, $ssh_key = undef, $registry_mount_host = false) {

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
