class openshift3::repo  {

  if $::operatingsystem == 'RedHat' {
    rhsm_repo { ['rhel-7-server-rpms', 'rhel-7-server-extras-rpms', 'rhel-7-server-optional-rpms']: 
      ensure  => present,
    }
  }

  if $::openshift3::deployment_type == 'enterprise' {
    rhsm_repo { 'rhel-server-7-ose-beta-rpms': 
      ensure  => absent,
    }

    rhsm_repo { "rhel-7-server-ose-${::openshift3::major}.${::openshift3::minor}-rpms":
      ensure  => present,
    }

    $old_ose_repos = split(inline_template('<%= (scope[\'::openshift3::minor\'].to_i - 1).downto(0) {|minor| "rhel-7-server-ose-#{scope[\'::openshift3::major\']}.#{minor}-rpms\n"} %>'), '\n')

    rhsm_repo { $old_ose_repos:
      ensure  => absent,
    }
  } else {
    yumrepo { "origin":
      descr => 'Copr repo for OpenShift origin',
      baseurl => 'https://copr-be.cloud.fedoraproject.org/results/maxamillion/origin-next/epel-7-$basearch/',
      enabled => 1,
      gpgcheck => 1,
      gpgkey => 'https://copr-be.cloud.fedoraproject.org/results/maxamillion/origin-next/pubkey.gpg',
      skip_if_unavailable => true,
    }
  }

  if $::openshift3::configure_epel {  
    yumrepo { "epel":
      descr => 'Extra Packages for Enterprise Linux 7',
      baseurl => "http://download.fedoraproject.org/pub/epel/7/x86_64",
      enabled => 0,
      gpgcheck => 1,
      gpgkey => "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7",
    }
  }
}
