define openshift3::set_volume ($namespace = 'default', $volume_name = undef, $claim_name = undef, $claim_size = undef) {
  exec { "Set volume ${volume_name} of ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc volume -n ${namespace} dc -l '${title}' --add --overwrite --name=${volume_name} -t pvc --claim-size=${claim_size} --claim-name=${claim_name}",
    unless      => "oc get -n ${namespace} pvc ${claim_name}",
    timeout     => 300,
    logoutput   => on_failure,
    path => $::path,
  } ~>

  exec { "Redeploy ${title} after setting ${volume_name}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc deploy -n ${namespace} -l '${title}' --latest",
    timeout     => 300,
    logoutput   => on_failure,
    path => $::path,
    refreshonly => true,
  }
}
