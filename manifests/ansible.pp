class openshift3::ansible {

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openshift/openshift-ansible.git",
    revision => 'master',
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

#   $_ansible_require = [Class['openshift3'], Package['ansible'],Augeas['ansible.cfg']]
#   if $::vagrant {
#      $ansible_require = concat($_ansible_require, File['/root/.ssh/id_rsa'], Ssh_Authorized_Key['ose3'], Class['openshift3::dns'])
#   } else {
#      $ansible_require = $_ansible_require
#   }

  # '.dnsConfig.bindAddress = "10.0.2.15:53"'

#    bindAddress: {{ openshift.master.bind_addr }}:{{ openshift.master.dns_port }}

#    yq { ".dnsConfig.bindAddress = \"${::network_primary_ip}:53\"":
#      file => '/etc/openshift/master/master-config.yaml',
#      notify => Service['openshift-master'],
#      require => Exec['Run ansible'],
#    } ->
#  }

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
    timeout => 1000,
#    logoutput => true,
#    require => $ansible_require,
  }

  if $::vagrant {
    file_line { 'Set DNS bind address':
      path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
      line => "  bindAddress: ${::network_primary_ip}:{{ openshift.master.dns_port }}",
      match => "^  bindAddress: {{ openshift.master.bind_addr }}:{{ openshift.master.dns_port }}$",
      require => Vcsrepo["/root/openshift-ansible"],
      before => Exec['Run ansible'],
    }
  }
}
