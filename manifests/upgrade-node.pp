class openshift3::upgrade-node {
  package { "${::openshift3::package_name}-node":
    ensure => latest,
  } ~>

  service { "${::openshift3::package_name}-node":
    enable => true,
  }
}
