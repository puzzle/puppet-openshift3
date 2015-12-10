class openshift3::proxy-master {

  augeas { "Set OpenShift Master Proxy":
    changes => [
      "set /files/etc/sysconfig/atomic-openshift-master/http_proxy http://outappl.pnet.ch:3128/",
      "set /files/etc/sysconfig/atomic-openshift-master/https_proxy http://outappl.pnet.ch:3128/",
      "set /files/etc/sysconfig/atomic-openshift-master/no_proxy 127.0.0.1,localhost,172.27.40.68,.pnet.ch,172.28.39.226",
    ],
    notify => Service['atomic-openshift-master'],
  }

}
