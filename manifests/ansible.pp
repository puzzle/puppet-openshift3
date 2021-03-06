class openshift3::ansible {

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openshift/openshift-ansible.git",
    revision => 'openshift-ansible-3.0.20-1',
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
    incl    => "/root/openshift-ansible/ansible.cfg",
    changes => ["set /files/root/openshift-ansible/ansible.cfg/defaults/host_key_checking False",
                "set /files/root/openshift-ansible/ansible.cfg/ssh_connection/pipelining True",], 
  } ->

#  run_upgrade_playbooks { "Run ansible upgrade playbooks":
#    playbooks => {
#      'playbooks/byo/openshift-cluster/upgrades/v3_0_minor/upgrade.yml' => { 'deployment_type' => 'enterprise', match_versions => '(3\.0\..*)' },
#      'playbooks/byo/openshift-cluster/upgrades/v3_0_to_v3_1/upgrade.yml' => { 'deployment_type' => 'enterprise', match_versions => '(3\.1)\..*' },
#    }
#  } ->

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
    timeout => 1000,
    logoutput => on_failure,
    path      => $::path,
  }

  if $::openshift3::openshift_dns_bind_addr {
    file_line { 'Set DNS bind address':
      path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
      line => "  bindAddress: ${::openshift3::openshift_dns_bind_addr}:{{ openshift.master.dns_port }}",
      match => "^  bindAddress: {{ openshift.master.bind_addr }}:{{ openshift.master.dns_port }}$",
      require => Vcsrepo["/root/openshift-ansible"],
      before => Exec['Run ansible'],
    }
  }

  file_line { 'Add logging URL to master config':
    path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
    after => 'assetConfig:',
    line => "  loggingPublicURL: \"https://logging.${::openshift3::app_domain}\"",
    match => "^  loggingPublicURL: .*",
    require => Vcsrepo["/root/openshift-ansible"],
    before => Exec['Run ansible'],
  }

  file_line { 'Add metrics URL to master config':
    path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
    after => 'assetConfig:',
    line => "  metricsPublicURL: \"https://metrics.${::openshift3::app_domain}/hawkular/metrics\"",
    match => "^  metricsPublicURL: .*",
    require => Vcsrepo["/root/openshift-ansible"],
    before => Exec['Run ansible'],
  }
}
