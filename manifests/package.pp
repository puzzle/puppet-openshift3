class openshift3::package  {

#  if $::openshift3::version {
#    yum_versionlock { ["${::openshift3::package_name}", "${::openshift3::package_name}-master", "${::openshift3::package_name}-node", "${::openshift3::package_name}-sdn-ovs", "${::openshift3::package_name}-clients", "tuned-profiles-${::openshift3::package_name}-node"]:
#      ensure => $::openshift3::version,
#    }
#  }

  if $::openshift3::ansible_from_epel {
    $switch_epel = "--enablerepo=${::openshift3::epel_repo_id}"
  } else {
    $switch_epel = "--disablerepo=${::openshift3::epel_repo_id}"
  }

  if $::openshift3::ansible_playbook_source == 'package' {
    yum_versionlock { ['ansible']:
      ensure      => absent,
      yum_options => $switch_epel,
    }
  }
  else {
    yum_versionlock { ['ansible']:
      ensure      => $::openshift3::real_ansible_version,
      yum_options => $switch_epel,
    }

    ensure_packages(["ansible-${::openshift3::real_ansible_version}"], {
      ensure          => latest,
      install_options => [$switch_epel, '--show-duplicates'],
      require         => Yum_versionlock['ansible'],
    })
  }

#  if $::openshift3::docker_version {
#    yum_versionlock { ["docker", "docker-selinux"]:
#      ensure => $::openshift3::docker_version,
#    }
#  }

#  Yum_versionlock <| |> ->

#  yumrepo { "epel":
#    descr => 'Extra Packages for Enterprise Linux 7',
#    baseurl => "http://download.fedoraproject.org/pub/epel/7/x86_64",
#    enabled => 0,
#    gpgcheck => 1,
#    gpgkey => "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7",
#  } ->

  yum_versionlock { [ 'atomic-openshift', 'atomic-openshift-clients' ]:
    ensure => $::openshift3::version,
  }

  ensure_packages(['atomic-openshift'], {
    ensure          => present,
    require         => [Yum_versionlock['atomic-openshift'], Yum_versionlock['atomic-openshift-clients']],
  })

  ensure_packages(['git', 'wget', 'yum-utils'], {
    ensure          => present,
  })

  ensure_packages(['jq'], {
    ensure          => present,
    install_options => "--enablerepo=${::openshift3::epel_repo_id}",
  })

#  package { ['deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'git', 'bridge-utils', 'iptables-services', 'pyOpenSSL', 'bash-completion' ]:
#    ensure => present,
#  }
}
