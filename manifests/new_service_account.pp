define openshift3::new_service_account ($namespace = 'default') {
  exec { "oc create with new sa ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "echo '{\"kind\":\"ServiceAccount\",\"apiVersion\":\"v1\",\"metadata\":{\"name\":\"${title}\"}}' | oc create --namespace=${namespace} -f -",
    unless      => "oc get sa --namespace=${namespace} ${title}",
    timeout     => 60,
  }
}
