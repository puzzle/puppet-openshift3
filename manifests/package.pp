class openshift3::package  {

  if $::openshift3::version {
    yum_versionlock { ["${::openshift3::package_name}", "${::openshift3::package_name}-master", "${::openshift3::package_name}-node", "${::openshift3::package_name}-sdn-ovs", "${::openshift3::package_name}-clients", "tuned-profiles-${::openshift3::package_name}-node"]:
      ensure => $::openshift3::version,
    }
  }

  if $::openshift3::docker_version {
    yum_versionlock { ["docker", "docker-selinux"]:
      ensure => $::openshift3::docker_version,
    }
  }

  Yum_versionlock <| |> ->

  package { ['ansible', 'jq']:
    ensure => present,
    install_options => '--enablerepo=epel',
  } ->

  package { ['deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'git', 'bridge-utils', 'iptables-services', 'pyOpenSSL' ]:
    ensure => present,
  }
}
