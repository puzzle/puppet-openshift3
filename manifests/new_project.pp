define openshift3::new_project () {
  exec { "new project ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oadm new-project ${title}",
    unless      => "oc get project ${title}",
    timeout     => 60,
  }
}
