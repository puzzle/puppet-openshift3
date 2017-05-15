class openshift3::registry {

  if $::openshift3::registry_image {
    $real_registry_image = $::openshift3::registry_image
  } else {
    $real_registry_image = "${::openshift3::component_prefix}-docker-registry:v${::openshift3::version}"
  }

  if $::openshift3::registry_mount_host {
    $mount_host = "--mount-host=/mnt/registry"

    file { 'Create registry local storage directory':
      path   => '/mnt/registry',
      ensure => directory,
      mode   => 0755,
    }

    exec { 'Create registry service account':
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => 'echo \
        \'{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"registry"}}\' \
        | oc create -n default -f -',
      unless => "oc get sa registry -n default",
      timeout => 600,
      path => $::path,
    } ->

    oc_replace { [
      '.users += ["system:serviceaccount:default:registry"]' ]:
      resource => 'scc/privileged',
      before => Exec['Install registry'],
    }
  } else {
    $mount_host = ""
  }  

  if $::openshift3::registry_node_selector {
    $selector = "--selector=${::openshift3::registry_node_selector}"
  } else {
    $selector = ""
  }

  if $::openshift3::registry_volume_size {
    set_volume { 'docker-registry':
      volume_name => 'registry-storage',
      claim_name => 'registry-storage',
      claim_size => $::openshift3::registry_volume_size,
      require => Exec['Install registry']
    }
  }

  exec { 'Install registry':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oc adm registry --namespace=default \
      --config=${::openshift3::conf_dir}/master/admin.kubeconfig \
      --credentials=${::openshift3::conf_dir}/master/openshift-registry.kubeconfig \
      --images=${real_registry_image} \
      ${mount_host} ${selector}",
    unless => "oc adm registry --namespace=default --dry-run",
    timeout => 600,
    path => $::path,
  } ->

  oc_replace { [
    ".spec.template.spec.containers[0].image = \"${real_registry_image}\"", ]:
    resource => 'dc/docker-registry',
  }

  if $::openshift3::registry_ip and $::openshift_registry_ip != $::openshift3::registry_ip {
    file { "/tmp/docker-registry.json":
      content   => template("openshift3/openshift/docker-registry.erb"),
      owner     => "root",
      group     => "root",
      mode      => 644,
    } ->

    exec { 'Delete registry service with wrong IP':
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => 'oc delete svc docker-registry -n default',
      timeout => 600,
      path => $::path,
      require => Exec['Install registry'],
    } ->

    exec { 'Create registry service with new IP':
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => 'oc create -n default -f /tmp/docker-registry.json',
      timeout => 600,
      path => $::path,
    }
  }
}
