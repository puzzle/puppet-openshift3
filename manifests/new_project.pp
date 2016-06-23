define openshift3::new_project ($options = '') {
  exec { "new project ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oadm new-project ${title} ${options}",
    unless      => "oc get project ${title}",
    timeout     => 60,
    path        => $::path,
  }
}
