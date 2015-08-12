class openshift3::registry {
  exec { 'Install registry':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "mkdir -p /mnt/registry && oadm registry --config=/etc/openshift/master/admin.kubeconfig \
      --credentials=/etc/openshift/master/openshift-registry.kubeconfig \
      --images='${::openshift3::component_images}'", # \
#      --mount-host=/mnt/registry",
    unless => "oadm registry",
    timeout => 600,
    require => Class['openshift3::router'],
  }

  oc_replace { [
    ".spec.template.spec.containers[0].image = \"${::openshift3::component_prefix}-docker-registry:v${::openshift3::version}\"", ]:
    resource => 'dc/docker-registry',
  }
}
