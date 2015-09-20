class openshift3::ansible {

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openshift/openshift-ansible.git",
    revision => '922b87ede66f6b7e376d1f46e13327077cd41719',
  } ->

  file { "/etc/ansible":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 755,
  } ->

  file { "/etc/ansible/hosts":
    content => template("openshift3/ansible/hosts.erb"),
    owner  => "root",
    group  => "root",
    mode   => 644,
  } ->

  augeas { "ansible.cfg":
    lens    => "Puppet.lns",
    incl    => "/root/openshift-ansible/ansible.cfg",
    changes => "set /files/root/openshift-ansible/ansible.cfg/defaults/host_key_checking False",
  } ->

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
    timeout => 1000,
    logoutput => true,
#    require => $ansible_require,
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
}
