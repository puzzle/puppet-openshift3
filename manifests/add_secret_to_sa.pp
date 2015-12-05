define openshift3::add_secret_to_sa ($namespace = 'default', $service_account) {
  exec { "oc secrets add ${service_account} ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc secrets add --namespace=${namespace} '${service_account}' '${title}'",
    unless      => "oc get sa --namespace=${namespace} '${service_account}' -o json | jq .secrets[].name | grep -q '\"${title}\"'",
    timeout     => 60,
  }
}
