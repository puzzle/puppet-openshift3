class openshift3::service-master {

  service { "${::openshift3::package_name}-master":
    enable => true,
  }
}
