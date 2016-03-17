define openshift3::set_volume ($namespace = 'default', $volume_name = undef, $claim_name = undef, $claim_size = undef) {
  exec { "Set volume ${volume_name} of ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc delete -n ${namespace} pvc ${claim_name} >/dev/null 2>&1; oc volume -n ${namespace} dc ${title} --add --overwrite --name=${volume_name} -t pvc --claim-size=${claim_size} --claim-name=${claim_name}",
    unless      => "oc get -n ${namespace} pvc ${claim_name} >/dev/null 2>&1;  oc get -n ${namespace} -o json dc ${title} | jq -e '..|select(.persistentVolumeClaim.claimName == \"${claim_name}\"?)'",
    timeout     => 300,
    logoutput   => on_failure,
    path => $::path,
  }

#  exec { "Redeploy ${title} after setting ${volume_name}":
#    provider    => 'shell',
#    environment => 'HOME=/root',
#    cwd         => "/root",
#    command     => "oc deploy -n ${namespace} -l '${title}' --latest",
#    timeout     => 300,
#    logoutput   => on_failure,
#    path => $::path,
#    refreshonly => true,
#  }
}
