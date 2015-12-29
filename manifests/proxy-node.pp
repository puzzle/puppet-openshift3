class openshift3::proxy-node {

  proxy_shellvars { "/etc/sysconfig/docker":
    http_proxy => $::openshift3::http_proxy,
    https_proxy => $::openshift3::https_proxy,
    no_proxy => $::openshift3::no_proxy,
    notify => Service['atomic-openshift-node'],
  }

  proxy_shellvars { "/etc/sysconfig/atomic-openshift-node":
    http_proxy => $::openshift3::http_proxy,
    https_proxy => $::openshift3::https_proxy,
    no_proxy => $::openshift3::no_proxy,
    notify => Service['atomic-openshift-node'],
  }
}
