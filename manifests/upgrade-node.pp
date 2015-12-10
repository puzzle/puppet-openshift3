class openshift3::upgrade-node {

  package { ["docker", "docker-selinux"]:
    ensure => latest,
  } ~>

  service { "docker":
    enable => true,
  } ->

  package { "${::openshift3::package_name}-node":
    ensure => latest,
  } ~>

  service { "${::openshift3::package_name}-node":
    enable => true,
  }
}
