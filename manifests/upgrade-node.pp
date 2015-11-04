class openshift3::upgrade-node {
  package { "${::openshift3::package_prefix}-node":
    ensure => latest,
  } ~>

  service { "${::openshift3::package_prefix}-node":
    enable => true,
  }
}
