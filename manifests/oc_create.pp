define openshift3::oc_create ($namespace = 'default', $resource = undef, $refreshonly = undef, $returns = undef, $logoutput = false) {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt = ""
  }

  exec { "oc_create $title":
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "echo '${title}' | oc create ${namespace_opt} -f -",
    unless => "oc get ${namespace_opt} '${resource}'",
    timeout => 600,
    refreshonly => $refreshonly,
    returns => $returns,
    logoutput => $logoutput,
  }
}
