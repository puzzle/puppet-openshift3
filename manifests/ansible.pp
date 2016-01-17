class openshift3::ansible {

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openshift/openshift-ansible.git",
    revision => 'openshift-ansible-3.0.32-1',
  } ->

  file { "/etc/ansible":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 755,
  } ->

  file { "/etc/ansible/hosts":
    content   => template("openshift3/ansible/hosts.erb"),
    owner     => "root",
    group     => "root",
    mode      => 644,
    show_diff => no,
  } ->

  augeas { "ansible.cfg":
    lens    => "Puppet.lns",
    incl    => "/etc/ansible/ansible.cfg",
    changes => ["set /files/etc/ansible/ansible.cfg/defaults/host_key_checking False",
                "set /files/etc/ansible/ansible.cfg/ssh_connection/pipelining True",], 
  } ->

  file { "/var/lib/puppet-openshift3/ansible":
    source   => "puppet:///modules/openshift3/ansible",
    owner     => "root",
    group     => "root",
    recurse    => true,
  } ->

#  run_upgrade_playbooks { "Run ansible upgrade playbooks":
#    playbooks => {
#      'playbooks/byo/openshift-cluster/upgrades/v3_0_minor/upgrade.yml' => { 'deployment_type' => 'enterprise', match_versions => '(3\.0\..*)' },
#      'playbooks/byo/openshift-cluster/upgrades/v3_0_to_v3_1/upgrade.yml' => { 'deployment_type' => 'enterprise', match_versions => '(3\.1)\..*' },
#    }
#  } ->

  notify { 'Run OpenShift prepare playbook': } ->

  exec { 'Run OpenShift prepare playbook':
    cwd     => "/var/lib/puppet-openshift3/ansible",
    command => "ansible-playbook prepare.yml -e 'openshift_package_name=${openshift3::package_name} openshift_version=${openshift3::version} openshift_major=${openshift3::major} openshift_minor=${openshift3::minor} docker_version=${openshift3::docker_version} vagrant=\"${::vagrant}\" openshift_master_ip=${openshift3::master_ip}'",
    timeout => 1000,
    logoutput => on_failure,
    path => $::path,
  } ->

  notify { 'Run OpenShift install/config playbook': } ->

  exec { 'Run OpenShift install/config playbook':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
    timeout => 1000,
    logoutput => on_failure,
    path      => $::path,
  } ->

  notify { 'Run OpenShift post-install playbook': } ->

  exec { 'Run OpenShift post-install playbook':
    cwd     => "/var/lib/puppet-openshift3/ansible",
    command => "ansible-playbook post-install.yml -e 'openshift_package_name=${openshift3::package_name} openshift_version=${openshift3::version} openshift_major=${openshift3::major} openshift_minor=${openshift3::minor} docker_version=${openshift3::docker_version} vagrant=\"${::vagrant}\" openshift_master_ip=${openshift3::master_ip}'",
    timeout => 1000,
    logoutput => on_failure,
    path => $::path,
  }

  if $::openshift3::openshift_dns_bind_addr {
    file_line { 'Set DNS bind address':
      path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
      line => "  bindAddress: ${::openshift3::openshift_dns_bind_addr}:{{ openshift.master.dns_port }}",
      match => "^  bindAddress: {{ openshift.master.bind_addr }}:{{ openshift.master.dns_port }}$",
      require => Vcsrepo["/root/openshift-ansible"],
      before => Exec['Run OpenShift install/config playbook'],
    }
  }

  file_line { 'Add logging URL to master config':
    path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
    after => 'assetConfig:',
    line => "  loggingPublicURL: \"https://logging.${::openshift3::app_domain}\"",
    match => "^  loggingPublicURL: .*",
    require => Vcsrepo["/root/openshift-ansible"],
    before => Exec['Run OpenShift install/config playbook'],
  }

  file_line { 'Add metrics URL to master config':
    path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
    after => 'assetConfig:',
    line => "  metricsPublicURL: \"https://metrics.${::openshift3::app_domain}/hawkular/metrics\"",
    match => "^  metricsPublicURL: .*",
    require => Vcsrepo["/root/openshift-ansible"],
    before => Exec['Run OpenShift install/config playbook'],
  }
}
