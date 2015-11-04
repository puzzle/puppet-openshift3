class openshift3::package  {

  if $::operatingsystem == 'RedHat' {
    rhsm_repo { ['rhel-7-server-rpms', 'rhel-7-server-extras-rpms', 'rhel-7-server-optional-rpms']: 
      ensure  => present,
    }
  }

  if $::openshift3::deployment_type == 'enterprise' {
    rhsm_repo { 'rhel-server-7-ose-beta-rpms': 
      ensure  => absent,
    }

    rhsm_repo { 'rhel-7-server-ose-3.0-rpms':
      ensure  => present,
    }
  }
  
  yumrepo { "epel":
    descr => 'Extra Packages for Enterprise Linux 7',
    baseurl => "http://download.fedoraproject.org/pub/epel/7/x86_64",
    enabled => 0,
    gpgcheck => 1,
    gpgkey => "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7",
  } ->

  package { ['ansible', 'jq']:
    ensure => present,
    install_options => '--enablerepo=epel',
  }

  if $::openshift3::package_version {
    yum::versionlock { ["0:${::openshift3::package_prefix}-${::openshift3::package_version}.x86_64", "0:${::openshift3::package_prefix}-master-${::openshift3::package_version}.x86_64", "0:${::openshift3::package_prefix}-node-${::openshift3::package_version}.x86_64", "0:${::openshift3::package_prefix}-sdn-ovs-${::openshift3::package_version}.x86_64", "0:tuned-profiles-${::openshift3::package_prefix}-node-${::openshift3::package_version}.x86_64"]:
      ensure => present,
    }
  }

  package { ['docker', 'docker-selinux', 'deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'git', 'bridge-utils', 'iptables-services' ]:
    ensure => present,
  }
}
