define openshift3::failover_router ($label = $title, $replicas, $interface = undef, $ips, $vrrp_id_offset = 0) {

  if $interface {
    $interface_opt = "--interface=${interface}"
  } else {
    $interface_opt = ""
  }

  if $::openshift3::failover_router_replicas {
    $dc = "ha-router"
  } else {
    $dc = "ha-router-${label}"
  }

  if $::openshift3::failover_router_image {
    $real_router_image = $::openshift3::failover_router_image
  } elsif $::openshift3::failover_routers['image'] {
    $real_router_image = $::openshift3::failover_routers['image']
  } else {
    $real_router_image = "${::openshift3::component_prefix}-haproxy-router:v${::openshift3::version}"
  }

  if $::openshift3::failover_keepalived_image {
    $real_keepalived_image = $::openshift3::failover_keepalived_image
  } elsif $::openshift3::failover_routers['keepalived_image'] {
    $real_keepalived_image = $::openshift3::failover_routers['keepalived_image']
  } else {
    $real_keepalived_image = "${::openshift3::component_prefix}-keepalived-ipfailover:v${::openshift3::version}"
  }

  exec { "Install HA router ${dc}":
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oadm router -n default --default-cert=cloudapps.router.pem ${dc} --replicas=${replicas} \
--selector=\"ha-router=${label}\" --labels=\"ha-router=${label}\" \
--credentials=${::openshift3::conf_dir}/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover",
    unless => "oc get svc/${dc} -n default",
    timeout => 600,
    path => $::path,
  } ->

  exec { "Install failover service ${dc}":
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oadm ipfailover -n default ipf-${dc} --replicas=${replicas} --watch-port=80 \
--selector=\"ha-router=${label}\" --virtual-ips=\"${ips}\" \
${interface_opt} --vrrp-id-offset=${vrrp_id_offset} \
--credentials=${::openshift3::conf_dir}/master/openshift-router.kubeconfig \
--images='${::openshift3::component_images}' \
--service-account=ipfailover --create",
    unless => "oc get dc/ipf-${dc} -n default",
    timeout => 600,
    path => $::path,
  } ->

  ansible_module { "Configure dc/${dc}":
    cwd    => '/var/lib/puppet-openshift3/ansible/roles/ansible-module-openshift/library',
    module => 'openshift_resource.py',
    args   => {
      namespace => 'default',
      patch     => parseyaml("
        kind: DeploymentConfig
        metadata:
          name: ${dc}
        spec:
          template:
            spec:
              containers:
                - name: router
                  image: ${real_router_image}"),
    }
  } ->

  ansible_module { "Configure dc/ipf-${dc}":
    cwd    => '/var/lib/puppet-openshift3/ansible/roles/ansible-module-openshift/library',
    module => 'openshift_resource.py',
    args   => {
      namespace => 'default',
      patch     => parseyaml("
        kind: DeploymentConfig
        metadata:
          name: ipf-${dc}
        spec:
          template:
            spec:
              containers:
                - name: ipf-${dc}-keepalived
                  image: ${real_keepalived_image}
                  env:
                    - name: OPENSHIFT_HA_VRRP_ID_OFFSET
                      value: \"${vrrp_id_offset}\""),
      }
    }
}
