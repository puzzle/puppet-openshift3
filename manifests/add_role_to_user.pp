define openshift3::add_role_to_user ($namespace = 'default', $role_type = 'local', $user = undef) {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt =""
  }

  if $role_type == 'cluster' {
    $command = 'add-cluster-role-to-user'
    $resource = 'clusterrolebinding'
  } else {
    $command = 'add-role-to-user'
    $resource = 'rolebinding'
  }

  exec { "add ${role_type} role ${title} to user ${user}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oadm policy ${command} ${namespace_opt} '${title}' '${user}'",
    unless      => "oc get ${namespace_opt} ${resource} -o json | jq '.items[] | select(.roleRef.name == \"${title}\").userNames' | grep -q '\"${user}\"'",
    timeout     => 60,
    logoutput   => on_failure,
  }
}
