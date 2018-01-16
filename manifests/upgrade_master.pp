class openshift3::upgrade_master {
  if $::openshift3::deployment_type == "enterprise" {
    $distro = "rhel7"
  } else {
    $distro = "centos7"
  }

  package { "${::openshift3::package_name}-master":
    ensure => latest,
  }

  if ! $::openshift3::master_cluster_method {
    Package["${::openshift3::package_name}-master"] ~> Service["${::openshift3::package_name}-master"]
  }
}
