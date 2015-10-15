class openshift3::failover {

  firewall { '500 Allow multicast ':
      action => 'accept',
      state  => 'NEW',
      destination => '224.0.0.18/32',
  } ->

  oc_create { '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"ipfailover"}}':
    resource => 'sa/ipfailover',
  } ->

  oc_replace { [
    '.users += ["system:serviceaccount:default:ipfailover"]', ]:
    resource => 'scc/privileged',
  } ->

  exec { 'Install HA router':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oadm router --default-cert=cloudapps.router.pem ha-router-eh --replicas=2 \
--selector=\"ha-router=eh\" --labels=\"ha-router=eh\" \
--credentials=/etc/openshift/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover",
    unless => "oc get svc/ha-router-eh -n default",
    timeout => 600,
  } ->


  exec { 'Install failover service':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oadm ipfailover ipf-ha-router-eh --replicas=2 --watch-port=80 \
--selector=\"ha-router=eh\" --virtual-ips=\"172.28.39.10-11\" \
--credentials=/etc/openshift/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover --create",
    unless => "oc get dc/ipf-ha-router-eh -n default",
    timeout => 600,
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
