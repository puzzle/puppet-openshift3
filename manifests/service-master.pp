class openshift3::service-master {

  if ! $::openshift3::master_cluster_method {
    service { "${::openshift3::package_name}-master":
      enable => true,
    }
  }
}
