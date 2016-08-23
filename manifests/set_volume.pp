define openshift3::set_volume ($namespace = 'default', $volume_name = undef, $claim_name = undef, $claim_size = undef, $host_path = undef) {
  if $claim_name {
    exec { "Create volume claim for ${volume_name} of ${title}":
      provider    => 'shell',
      environment => 'HOME=/root',
      cwd         => "/root",
      command     => "echo '{\"kind\":\"PersistentVolumeClaim\",\"apiVersion\":\"v1\",\"metadata\":{\"name\":\"${claim_name}\",\"creationTimestamp\":null},\"spec\":{\"accessModes\":[\"ReadWriteOnce\"],\"resources\":{\"requests\":{\"storage\":\"${claim_size}\"}}},\"status\":{}}' | oc create --namespace=${namespace} -f -",
      unless      => "oc get -n ${namespace} pvc ${claim_name}",
      timeout     => 30,
      logoutput   => on_failure,
      path => $::path,
    } ->

    exec { "Set volume ${volume_name} of ${title}":
      provider    => 'shell',
      environment => 'HOME=/root',
      cwd         => "/root",
      command     => "oc volume -n ${namespace} dc ${title} --add --overwrite --name=${volume_name} -t pvc --claim-name=${claim_name}",
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
