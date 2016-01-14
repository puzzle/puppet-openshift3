define openshift3::instantiate_template ($template_namespace = 'openshift', $template_parameters = undef, $resource_namespace = 'default', $creates) {
  if $template_parameters {
    $parameters_opt = "-v '${template_parameters}'"
  } else {
   $parameters_opt = ""
  }

  exec { "instantiate template ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc process ${title} -n ${template_namespace} ${parameters_opt} | oc create -n ${resource_namespace} -f -",
#    unless      => "oc get ${namespace_opt} ${resource} -o json | jq '.items[] | select(.roleRef.name == \"${title}\").userNames' | grep -q '\"${user}\"'",
#oc get template logging-support-template -o json  | jq '.objects[] | "\(.kind) \(.metadata.name // .metadata.generateName)"'
    unless      => "oc get -n ${resource_namespace} ${creates}",
    timeout     => 300,
    logoutput   => on_failure,
    path => $::path,
  } ->

  exec { "wait for template instantiation ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc get -n ${resource_namespace} ${creates}",
    unless      => "oc get -n ${resource_namespace} ${creates}",
    try_sleep   => 1,
    tries       => 120,
    timeout     => 5,
    path        => $::path,
  }
}
