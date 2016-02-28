class openshift3::upgrade-master {
  if $::openshift3::deployment_type == "enterprise" {
    $distro = "rhel7"
  } else {
    $distro = "centos7"
  }

  package { "${::openshift3::package_name}-master":
    ensure => latest,
    notify => Service["${::openshift3::package_name}-master"],
  } ->

  oc_replace { [
    "/usr/share/openshift/examples/image-streams/image-streams-${distro}.json",
    '/usr/share/openshift/examples/db-templates/',
    '/usr/share/openshift/examples/quickstart-templates/' ]:
    namespace => 'openshift',
  }
}
