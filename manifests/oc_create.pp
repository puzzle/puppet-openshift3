define openshift3::oc_create ($namespace = 'default', $resource = undef, $unless = undef, $refreshonly = undef, $returns = undef, $logoutput = false) {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt = ""
  }

  ensure_resource('file', '/var/lib/puppet-openshift3', { ensure => directory })

  exec { "oc_create $title":
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oc create ${namespace_opt} -f '${title}'",
    unless => $unless,
    timeout => 600,
    refreshonly => $refreshonly,
    returns => $returns,
    logoutput => $logoutput,
  }
}
