class openshift3::registry {

  if $::openshift3::registry_mount_host {
    $mount_host = "--mount-host=/mnt/registry --service-account=registry"

     exec { 'Create registry service account':
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => 'echo \
        \'{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"registry"}}\' \
        | oc create -n default -f -',
      unless => "oc get sa registry -n default",
      timeout => 600,
    } ->

    oc_replace { [
      '.users += ["system:serviceaccount:default:registry"]' ]:
      resource => 'scc/privileged',
      before => Exec['Install registry'],
    }
  } else {
    $mount_host = ""
  }  

  exec { 'Install registry':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "mkdir -p /mnt/registry && oadm registry -n default --config=/etc/openshift/master/admin.kubeconfig \
      --credentials=/etc/openshift/master/openshift-registry.kubeconfig \
      --images='${::openshift3::component_images}' \
      ${mount_host}",
    unless => "oadm registry -n default",
    timeout => 600,
  } ->

  oc_replace { [
    ".spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-docker-registry:v${::openshift3::version}\"", ]:
    resource => 'dc/docker-registry',
  }
}
