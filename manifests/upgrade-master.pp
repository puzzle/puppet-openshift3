class openshift3::upgrade-master {
  if $::openshift3::deployment_type == "enterprise" {
    $distro = "rhel7"
  } else {
    $distro = "centos7"
  }

  package { "${::openshift3::package_name}-master":
    ensure => latest,
  } ~>

  service { "${::openshift3::package_name}-master":
    enable => true,
  } ->

  oc_replace { [
    "/usr/share/openshift/examples/image-streams/image-streams-${distro}.json",
    '/usr/share/openshift/examples/db-templates/',
    '/usr/share/openshift/examples/quickstart-templates/' ]:
    namespace => 'openshift',
  } ->

  exec {"Wait for master":
    command => "/usr/bin/wget --spider --tries 60 --retry-connrefused --no-check-certificate https://localhost:8443/",
    unless => "/usr/bin/wget --spider --no-check-certificate https://localhost:8443/",
  }
}
