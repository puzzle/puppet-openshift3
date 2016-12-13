class openshift3::router {

  if $::openshift3::install_router {
    if $::openshift3::router_image {
      $real_router_image = $::openshift3::router_image
    } else {
      $real_router_image = "${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}"
    }

    oc_create { '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"router"}}':
      resource => 'sa/router',
    } ->

    oc_replace { [
      '.users += ["system:serviceaccount:default:router"]',
      '.allowHostNetwork = true',
      '.allowHostPorts = true', ]:
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

    exec { 'Install router':
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => "oadm router --namespace=default --default-cert=cloudapps.router.pem router --replicas=1 \
        --credentials=${::openshift3::conf_dir}/master/openshift-router.kubeconfig \
        --images='${::openshift3::component_images}' \
        --service-account=router",
      unless => "oc get svc/router -n default",
      timeout => 600,
      path => $::path,
    } ->

    oc_replace { [
      '.spec.strategy.rollingParams.updatePercent = -10',
      '.spec.template.spec.serviceAccount = "router"',
      '.spec.template.spec.serviceAccountName = "router"',
      '.spec.template.spec.hostNetwork = true',
      ]:
      resource => 'dc/router',
    } ->

    oc_replace { [
      ".spec.template.spec.containers[0].image = \"${real_router_image}\"", ]:
      resource => 'dc/router',
    }
  }
}
