class openshift3::failover {

  if $::openshift3::failover_router_replicas {

    if $::openshift3::failover_router_image {
      $real_router_image = $::openshift3::failover_router_image
    } else {
      $real_router_image = "${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}"
    }

    if $::openshift3::failover_keepalived_image {
      $real_keepalived_image = $::openshift3::failover_keepalived_image
    } else {
      $real_keepalived_image = "${::openshift3::component_prefix}-keepalived-ipfailover:v${::openshift3::version}"
    }

  oc_create { '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"ipfailover"}}':
    resource => 'sa/ipfailover',
  } ->

  oc_replace { [
    '.users += ["system:serviceaccount:default:ipfailover"]' ]:
    resource => 'scc/privileged',
  } ->

  exec { "Create wildcard certificate":
      provider => 'shell',
      environment => ["CA=/${::openshift3::conf_dir}/master"],
      cwd     => "/root",
      command => "oadm create-server-cert --signer-cert=\$CA/ca.crt \
        --signer-key=\$CA/ca.key --signer-serial=\$CA/ca.serial.txt \
        --hostnames='*.${::openshift3::app_domain}' \
        --cert=cloudapps.crt --key=cloudapps.key && cat cloudapps.crt cloudapps.key \$CA/ca.crt > cloudapps.router.pem",
      creates => '/root/cloudapps.router.pem',
      path => $::path,
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
--interface=${::openshift3::failover_router_interface} \
--credentials=${::openshift3::conf_dir}/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover --create",
    unless => "oc get dc/ipf-ha-router -n default",
    timeout => 600,
    path => $::path,
  } ->

#  oc_replace { [
#    '.spec.strategy.rollingParams.updatePercent = -10',
#    '.spec.template.spec.serviceAccount = "router"',
#    '.spec.template.spec.serviceAccountName = "router"',
#    '.spec.template.spec.hostNetwork = true',
#    '.spec.template.spec.containers[0].hostNetwork = true',
#    ]:
#    resource => 'dc/router',
#  } ->
   
    oc_replace { [
      ".spec.template.spec.containers[0].image = \"${real_router_image}\"", ]:
      resource => 'dc/ha-router',
    } ->

    oc_replace { [
      ".spec.template.spec.containers[0].image = \"${real_keepalived_image}\"", ]:
      resource => 'dc/ipf-ha-router',
    }
  }
}
