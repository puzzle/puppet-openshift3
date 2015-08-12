class openshift3::upgrade {
  package { 'openshift-master':
    ensure => latest,
  } ~>

  service { 'openshift-master':
    enable => true,
  } ~>

  oc_create { [
    '/usr/share/openshift/examples/image-streams/image-streams-centos7.json',
    '/usr/share/openshift/examples/db-templates',
    '/usr/share/openshift/examples/quickstart-templates' ]:
    namespace => 'openshift',
    refreshonly => true,
    returns => [0, 1],
  } ~>

  oc_replace { [
    '/usr/share/openshift/examples/image-streams/image-streams-centos7.json',
    '/usr/share/openshift/examples/db-templates',
    '/usr/share/openshift/examples/quickstart-templates' ]:
    namespace => 'openshift',
    refreshonly => true,
  } ->

  package { 'openshift-node':
    ensure => latest,
  } ~>

  service { 'openshift-node':
    enable => true,
  } ->

  exec {"Wait for master":
    command => "/usr/bin/wget --spider --tries 60 --retry-connrefused --no-check-certificate https://localhost:8443/",
  }
}
