class openshift3 ($deployment_type = "origin", $package_version = undef, $ssh_key = undef) {

  if $deployment_type == "enterprise" {
    $component_prefix = 'registry.access.redhat.com/openshift3/ose'
    $component_images = "${component_prefix}-\${component}:\${version}"
  } else {
    $component_prefix = 'openshift/origin'
    $component_images = "${component_prefix}-\${component}:\${version}"
  }

  $versionrel = split($package_version, '-')
  $version = $versionrel[0]

  if $::vagrant {
    ssh_authorized_key { "${ssh_key[name]}":
      user => 'root',
      type => $ssh_key[type],
      key  => $ssh_key[key],
    }
  }
}
