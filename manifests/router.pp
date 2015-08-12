class openshift3::router {

  exec { 'Create router service account':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => 'echo \
      \'{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"router"}}\' \
      | oc create -f -',
    unless => "oc get sa router",
    timeout => 600,
  } ->

#  oc_replace('Make router service account privileged', 'scc/privileged', {
#    '.users' => ["system:serviceaccount:default:router"],
#    '.allowHostNetwork' => true,
#    '.allowHostPorts' => true
#  })

  oc_replace { [
    '.users += ["system:serviceaccount:default:router"]',
    '.allowHostNetwork = true',
    '.allowHostPorts = true', ]:
    resource => 'scc/privileged',
  } ->

  
#  oq { 'Make router service account privileged':
#    resource => 'scc/privileged',
#    update => '.users = .users + ["system:serviceaccount:default:router"]',
#    unless => '.users | contains(["system:serviceaccount:default:router"])',
#  }

#  exec { 'Make router service account privileged':
#    provider => 'shell',
#    environment => 'HOME=/root',
#    cwd     => "/root",
#    command => "oq scc/privileged ! '.users = .users + [\"system:serviceaccount:default:router\"]'",
#    unless => "oq scc/privileged ? '.users | contains([\"system:serviceaccount:default:router\"])'",
#    timeout => 600,
#  } ->


#  exec { "Create wildcard certificate":
#    provider => 'shell',
#    environment => ['HOME=/root', 'CA=/etc/openshift/master'],
#    cwd     => "/root",
#    command => "oadm create-server-cert --signer-cert=\$CA/ca.crt \
#      --signer-key=\$CA/ca.key --signer-serial=\$CA/ca.serial.txt \
#      --hostnames='*.cloudapps.example.com' \
#      --cert=cloudapps.crt --key=cloudapps.key && cat cloudapps.crt cloudapps.key \$CA/ca.crt > cloudapps.router.pem",
#    creates => '/root/cloudapps.router.pem',
#    require => [Service['openshift-master'], Exec['Run ansible'], Exec['Wait for master']],
#  }

  exec { 'Install router':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
#    command => "oadm router --default-cert=cloudapps.router.pem \
    command => "oadm router router --replicas=1 \
--credentials=/etc/openshift/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=router",
    unless => "oadm router",
    timeout => 600,
#    require => Exec['Create wildcard certificate'],
#    require => Exec['Make router service account privileged'],
  } ->

  oc_replace { [
    '.spec.strategy.rollingParams.updatePercent = -10',
#     '.spec.strategy = { type: "Recreate", resources: { } }',
    '.spec.template.spec.serviceAccount = "router"',
    '.spec.template.spec.serviceAccountName = "router"',
#    ".spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-haproxy-router:latest\"", ]:
    ]:
    resource => 'dc/router',
  } ->

  oc_replace { [
    ".spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"", ]:
    resource => 'dc/router',
  }

#  oq { 'Set router deployment config':
#    resource => 'dc/router',
#    values => {
#      '.spec.strategy.rollingParams.updatePercent' => '-10',
#      '.spec.template.spec.serviceAccount' => '"router"',
#      '.spec.template.spec.serviceAccountName' => '"router"',
#      '.spec.template.spec.containers[0].image' => "\"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"",
 
#    update => ".spec.strategy.rollingParams.updatePercent = -10 | \
#      .spec.template.spec.serviceAccount = \"router\" | \
#      .spec.template.spec.serviceAccountName = \"router\" | \
#      .spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"",
#    unless => ".spec.strategy.rollingParams.updatePercent == -10 and \
#      .spec.template.spec.serviceAccount == \"router\" and \
#      .spec.template.spec.serviceAccountName = \"router\" and \
#      .spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"",
#    logoutput => true,
#  }

#  oq { 'Set router service account':
#    resource => 'dc/router',
#    update => ".spec.strategy.rollingParams.updatePercent = \"-10\"",
#    unless => ".spec.strategy.rollingParams.updatePercent == \"-10\"",
#  }

#  oq { 'Set router image version':
#    resource => 'dc/router',
#    update => ".spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"",
#    unless => ".spec.template.spec.containers[0].image == \"${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}\"",
#  }
}
