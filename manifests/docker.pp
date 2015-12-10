class openshift3::docker {

  file_line { 'Set docker log level':
    path => '/etc/sysconfig/docker',
    line => "OPTIONS='--insecure-registry=172.30.0.0/16 --selinux-enabled --log-level=warn'",
    match => "^OPTIONS=.*$",
    notify => Service['docker'],
  }


}
