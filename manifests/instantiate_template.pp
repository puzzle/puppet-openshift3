define openshift3::instantiate_template ($template_namespace = 'openshift', $template_parameters = undef, $resource_namespace = 'default', $returns = 0, $creates) {
  if $template_parameters {
    $parameters_opt = join(prefix($template_parameters, '-p '), ' ')
  } else {
    $parameters_opt = ""
  }

  exec { "instantiate template ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc new-app ${title} -n ${resource_namespace} ${parameters_opt}",
    unless      => "oc get -n ${resource_namespace} ${creates} | grep -q .",
    returns     => $returns,
    timeout     => 300,
    logoutput   => on_failure,
    path => $::path,
  } ->
  
  exec { "wait for template instantiation ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc get -n ${resource_namespace} ${creates} | grep -q .",
    unless      => "oc get -n ${resource_namespace} ${creates} | grep -q .",
    try_sleep   => 1,
    tries       => 120,
    timeout     => 5,
    path        => $::path,
  }
}
