class openshift3::service_master {

  if ! $::openshift3::master_cluster_method {
    service { "${::openshift3::package_name}-master":
      enable => true,
    }
  }
}
