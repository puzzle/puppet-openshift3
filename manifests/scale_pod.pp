define openshift3::scale_pod ($namespace = 'default', $pod = $title, $replicas) {
  if $replicas == 'ready_nodes' {
    $real_replicas = '$READY_NODES'
  } else {
    $real_replicas =  $replicas
  }

  exec { "Scale pod ${pod} in namespace ${namespace} to ${replicas} replicas":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "DEPLOYMENT=`oc get -n ${namespace} dc ${pod} -o json| jq .status.latestVersion` && \
                    READY_NODES=`oc get nodes -o json 2>/dev/null |jq -r '.items[] | select(.spec.unschedulable!=true and .status.conditions[0].status==\"True\").spec.externalID' 2>/dev/null | wc -l` && \
                    oc scale -n ${namespace} dc ${pod} --replicas=${real_replicas} && \
                    oc scale -n ${namespace} rc ${pod}-\$DEPLOYMENT --replicas=${real_replicas}",
    unless      => "DEPLOYMENT=`oc get -n ${namespace} dc ${pod} -o json| jq .status.latestVersion` && \
                    READY_NODES=`oc get nodes -o json 2>/dev/null |jq -r '.items[] | select(.spec.unschedulable!=true and .status.conditions[0].status==\"True\").spec.externalID' 2>/dev/null | wc -l` && \
                   [ `oc get -n ${namespace} dc ${pod} -o json | jq .spec.replicas` = \"${real_replicas}\" && \
                   [ `oc get -n ${namespace} rc ${pod}-\$DEPLOYMENT -o json | jq .status.replicas` = \"${real_replicas}\" ]",
    timeout     => 60,
    logoutput   => on_failure,
  }
}
