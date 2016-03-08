class openshift3::failover {

  if $::openshift3::failover_router_replicas {
  firewall { '500 Allow multicast ':
      action => 'accept',
      state  => 'NEW',
      destination => '224.0.0.18/32',
  } ->

  oc_create { '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"ipfailover"}}':
    resource => 'sa/ipfailover',
  } ->

  oc_replace { [
    '.users += ["system:serviceaccount:default:ipfailover"]' ]:
    resource => 'scc/privileged',
  } ->

  exec { 'Install HA router':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oadm router -n default --default-cert=cloudapps.router.pem ha-router --replicas=${::openshift3::failover_router_replicas} \
--selector=\"ha-router=${::openshift3::failover_router_label}\" --labels=\"ha-router=${::openshift3::failover_router_label}\" \
--credentials=${::openshift3::conf_dir}/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover",
    unless => "oc get svc/ha-router -n default",
    timeout => 600,
    path => $::path,
  } ->

  exec { 'Install failover service':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oadm ipfailover -n default ipf-ha-router --replicas=${::openshift3::failover_router_replicas} --watch-port=80 \
--selector=\"ha-router=${::openshift3::failover_router_label}\" --virtual-ips=\"${::openshift3::failover_router_ips}\" \
--credentials=${::openshift3::conf_dir}/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover --create",
    unless => "oc get dc/ipf-ha-router -n default",
    timeout => 600,
    path => $::path,
  }

#  oc_replace { [
#    '.spec.strategy.rollingParams.updatePercent = -10',
#    '.spec.template.spec.serviceAccount = "router"',
#    '.spec.template.spec.serviceAccountName = "router"',
#    '.spec.template.spec.hostNetwork = true',
#    '.spec.template.spec.containers[0].hostNetwork = true',
#    ]:
#    resource => 'dc/router',
#  } ->

#  oc_replace { [
#    ".spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"", ]:
#    namevar => "Update HA router image",
#    resource => 'dc/ha-router-eh',
#  }
  }
}
