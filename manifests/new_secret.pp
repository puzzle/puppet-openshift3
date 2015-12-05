define openshift3::new_secret ($namespace = 'default', $source) {
  exec { "oc secrets new ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc secrets new --namespace=${namespace} '${title}' '${source}'",
    unless      => "oc get secret --namespace=${namespace} '${title}'",
    timeout     => 60,
  }
}
