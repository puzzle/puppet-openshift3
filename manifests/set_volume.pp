define openshift3::set_volume ($namespace = 'default', $volume_name = undef, $claim_name = undef, $claim_size = undef, $claim_instances = 1, $host_path = undef) {
  if $claim_name {
    if $claim_instances == 1 {
      exec { "Set volume ${volume_name} of ${title}":
        provider    => 'shell',
        environment => 'HOME=/root',
        cwd         => "/root",
        command     => "oc volume -n ${namespace} dc ${title} --add --overwrite --name=${volume_name} -t pvc --claim-name=${claim_name} --claim-size=${claim_size}",
        unless      => "oc get -n ${namespace} -o json dc ${title} | jq -e '..|select(.persistentVolumeClaim.claimName == \"${claim_name}\"?)'",
        timeout     => 30,
        logoutput   => on_failure,
        path => $::path,
      }
    } else {
      exec { "Set volume ${volume_name} of ${title}":
        provider    => 'shell',
        environment => 'HOME=/root',
        cwd         => "/root",
        command     => "for i in `seq 1 $claim_instances`; do oc volume -n ${namespace} dc `oc get -n ${namespace} dc ${title} -o jsonpath=\"{.items[\$((i - 1))].metadata.name}\"` --add --overwrite --name=${volume_name} -t pvc --claim-name=${claim_name}-\$i --claim-size=${claim_size}; done",
        unless      => "oc get -n ${namespace} -o json dc ${title} | jq -e '..|select(.persistentVolumeClaim.claimName == \"${claim_name}-1\"?)'",
        timeout     => 30,
        logoutput   => on_failure,
        path => $::path,
      }
    }
  } else {
    exec { "Set volume ${volume_name} of ${title}":
      provider    => 'shell',
      environment => 'HOME=/root',
      cwd         => "/root",
      command     => "oc volume -n ${namespace} dc ${title} --add --overwrite --name=${volume_name} -t hostPath --path=${host_path}",
      unless      => "oc get -n ${namespace} -o json dc ${title} | jq -e '..|select(.hostPath.path == \"${host_path}\"?)'",
      timeout     => 30,
      logoutput   => on_failure,
      path => $::path,
    }
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
