class openshift3::proxy-master {

  proxy_shellvars { "/etc/sysconfig/atomic-openshift-master":
    http_proxy => $::openshift3::http_proxy,
    https_proxy => $::openshift3::https_proxy,
    no_proxy => $::openshift3::no_proxy,
    notify => Service['atomic-openshift-master'],
  }
}
