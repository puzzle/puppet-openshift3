class openshift3::failover_routers {
  
  if $::openshift3::failover_router_replicas or ! empty($::openshift3::failover_routers) {
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

    if versioncmp($::openshift3::version, '3.3.0') < 0 {
      oc_create { '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"ipfailover"}}':
        resource => 'sa/ipfailover',
        before => Oc_Replace['.users += ["system:serviceaccount:default:ipfailover"]'],
      }
    }

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
    }

    if $::openshift3::failover_router_replicas {
      failover_router { $::openshift3::failover_router_label:
        replicas => $::openshift3::failover_router_replicas,
        interface => $::openshift3::failover_router_interface,
        ips => $::openshift3::failover_router_ips,
        require => Exec["Create wildcard certificate"],
        before => Oc_Replace[".spec.template.spec.containers[0].image = \"${real_router_image}\""],
      }
    } else {
      create_resources('failover_router', $::openshift3::failover_routers['groups'], {
        require => Exec["Create wildcard certificate"],
        before => Oc_Replace[".spec.template.spec.containers[0].image = \"${real_router_image}\""],
      })
    }

    oc_replace { ".spec.template.spec.containers[0].image = \"${real_router_image}\"" :
      resource => 'dc/ha-router',
    } ->

    oc_replace { ".spec.template.spec.containers[0].image = \"${real_keepalived_image}\"":
      resource => 'dc/ipf-ha-router',
    }
  }
}
