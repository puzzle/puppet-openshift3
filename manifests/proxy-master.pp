class openshift3::proxy-master {

  proxy_shellvars { "/etc/sysconfig/atomic-openshift-master":
    http_proxy => $::openshift3::http_proxy,
    https_proxy => $::openshift3::https_proxy,
    no_proxy => $::openshift3::no_proxy,
  }

  if ! $::openshift3::master_cluster_method {
    Proxy_Shellvars['/etc/sysconfig/atomic-openshift-master'] ~> Service["${::openshift3::package_name}-master"]
  }
}
