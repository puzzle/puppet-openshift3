class openshift3::upgrade-node {
  package { 'openshift-node':
    ensure => latest,
  } ~>

  service { 'openshift-node':
    enable => true,
  }
}
