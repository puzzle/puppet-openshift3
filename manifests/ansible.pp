class openshift3::ansible {

  if $::openshift3::ansible_sudo {
    $sudo = 'sudo'
  } else {
    $sudo = ''
  }
  
  ensure_resource('file', ['/var/lib/puppet-openshift3/log',"${::openshift3::conf_dir}", "${::openshift3::conf_dir}/master"], { ensure => directory })

  if $::openshift3::ldap_ca_crt {
    file { "${::openshift3::conf_dir}/master/ldap-ca.crt":
      content => $::openshift3::ldap_ca_crt,
      owner => root,
      group => root,
      mode => 0640,
      show_diff => false,
      before => Run_Ansible['pre-install.yml'],
    }
  }

  if $::openshift3::ansible_playbook_source == 'package' {
    package { "openshift-ansible-playbooks":
      ensure => present,
    } ->

    file { "/root/openshift-ansible":
      ensure => link,
      target => "/usr/share/ansible/openshift-ansible/",
      before   => File["/etc/ansible"],
    }
  } else {
    vcsrepo { "/root/openshift-ansible":
      ensure   => latest,
      provider => git,
      source   => "https://github.com/openshift/openshift-ansible.git",
      revision => $::openshift3::openshift_ansible_version,
      before   => File["/etc/ansible"],
    }
  }

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
                "set /files/etc/ansible/ansible.cfg/ssh_connection/pipelining True",
                "set /files/etc/ansible/ansible.cfg/ssh_connection/control_path /tmp/ansible-ssh-%%h-%%p-%%r"], 
  } ->

  file { "/var/lib/puppet-openshift3/ansible":
    source   => "puppet:///modules/openshift3/ansible",
    owner     => "root",
    group     => "root",
    recurse   => true,
    ignore    => "\$HOME",
  } ->

  run_ansible { 'pre-install.yml':
    cwd => '/var/lib/puppet-openshift3/ansible',
    options => "-e 'openshift_package_name=${openshift3::package_name} openshift_component_prefix=${openshift3::component_prefix} openshift_version=${openshift3::version} openshift_major=${openshift3::major} openshift_minor=${openshift3::minor} docker_version=${openshift3::real_docker_version} vagrant=\"${::vagrant}\" openshift_master_ip=${openshift3::master_ip} configure_epel=${openshift3::configure_epel} epel_repo_id=${openshift3::epel_repo_id} master_style_repo_url=${openshift3::master_style_repo_url} master_style_repo_ref=${openshift3::master_style_repo_ref} master_style_repo_ssh_key=${openshift3::master_style_repo_ssh_key} ansible_pkg_version=${openshift3::ansible_version}'",
    check_options => '-u',
  } ->

  run_upgrade_playbooks { "Run ansible upgrade playbooks":
    playbooks => {
      'playbooks/byo/openshift-cluster/upgrades/v3_0_minor/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.0', if_new_ver => '3.0' },
      'playbooks/byo/openshift-cluster/upgrades/v3_1_minor/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.1', if_new_ver => '3.1' },
      'playbooks/byo/openshift-cluster/upgrades/v3_0_to_v3_1/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.0', if_new_ver => '3.1' },
      'playbooks/byo/openshift-cluster/upgrades/v3_1_to_v3_2/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.1', if_new_ver => '3.2' },     
      'playbooks/byo/openshift-cluster/upgrades/v3_2/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.2', if_new_ver => '3.2' },
    }
  } ->

  run_ansible { 'playbooks/byo/config.yml':
    cwd     => "/root/openshift-ansible",
    options => "-e \"repoquery_cmd='repoquery --plugins --pkgnarrow=all'\"",
  } ->

  run_ansible { 'post-install.yml':
    cwd     => "/var/lib/puppet-openshift3/ansible",
    options => "-e 'openshift_package_name=${openshift3::package_name} openshift_component_prefix=${openshift3::component_prefix} openshift_version=${openshift3::version} openshift_major=${openshift3::major} openshift_minor=${openshift3::minor} docker_version=${openshift3::real_docker_version} vagrant=\"${::vagrant}\" openshift_master_ip=${openshift3::master_ip} http_proxy=${openshift3::http_proxy} https_proxy=${openshift3::https_proxy} no_proxy=${openshift3::no_proxy}'",
  } ->

  exec {"Wait for master":
    command => "/usr/bin/wget --spider --tries 60 --retry-connrefused --no-check-certificate https://${openshift3::master}:8443/",
    unless => "/usr/bin/wget --spider --no-check-certificate https://${openshift3::master}:8443/",
    path => $::path,
  } ->

  exec {"Copy OpenShift config and certificates from first master":
    command => "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${openshift3::ansible_ssh_user}@${openshift3::master} ${sudo} bash -c \\''cd /etc && tar cf - origin'\\' | ( cd /etc && tar xf - )",
    creates => '/etc/origin/master/ca.crt',
    path => $::path,
  } ->

  exec {"Copy kubeconfig from first master":
    command => "/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${openshift3::ansible_ssh_user}@${openshift3::master} ${sudo} bash -c \\''cd /root && tar cf - .kube'\\' | ( cd /root && tar xf - )",
    creates => '/root/.kube',
    path => $::path,
  }
}
