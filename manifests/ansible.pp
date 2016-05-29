class openshift3::ansible {

  ensure_resource('file', ['/var/lib/puppet-openshift3/log',"${::openshift3::conf_dir}", "${::openshift3::conf_dir}/master"], { ensure => directory })

  if $::openshift3::ldap_ca_crt {
    file { "${::openshift3::conf_dir}/master/ldap-ca.crt":
      content => $::openshift3::ldap_ca_crt,
      owner => root,
      group => root,
      mode => 0640,
      show_diff => false,
      before => Notify['Run OpenShift prepare playbook'],
    }
  }

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openshift/openshift-ansible.git",
    revision => 'openshift-ansible-3.0.94-1',
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
    recurse   => true,
    ignore    => "\$HOME",
  } ->

  notify { 'Run OpenShift prepare playbook': } ->

  exec { 'Run OpenShift prepare playbook':
    provider => "shell",
    cwd     => "/var/lib/puppet-openshift3/ansible",
    command => "set -o pipefail; stdbuf -o L ansible-playbook prepare.yml -e 'openshift_package_name=${openshift3::package_name} openshift_component_prefix=${openshift3::component_prefix} openshift_version=${openshift3::version} openshift_major=${openshift3::major} openshift_minor=${openshift3::minor} docker_version=${openshift3::docker_version} vagrant=\"${::vagrant}\" openshift_master_ip=${openshift3::master_ip} configure_epel=${openshift3::configure_epel} epel_repo_id=${openshift3::epel_repo_id} master_style_repo_url=${openshift3::master_style_repo_url} master_style_repo_ref=${openshift3::master_style_repo_ref} master_style_repo_ssh_key=${openshift3::master_style_repo_ssh_key} ansible_version=${openshift3::ansible_version}' | tee /var/lib/puppet-openshift3/log/ansible-pre-install.log",
    timeout => 1000,
    logoutput => on_failure,
    path => $::path,
  } ->

  run_upgrade_playbooks { "Run ansible upgrade playbooks":
    playbooks => {
      'playbooks/byo/openshift-cluster/upgrades/v3_0_minor/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.0', if_new_ver => '3.0' },
      'playbooks/byo/openshift-cluster/upgrades/v3_1_minor/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.1', if_new_ver => '3.1' },
      'playbooks/byo/openshift-cluster/upgrades/v3_0_to_v3_1/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.0', if_new_ver => '3.1' },
      'playbooks/byo/openshift-cluster/upgrades/v3_1_to_v3_2/upgrade.yml' => { 'if_deployment_type' => 'enterprise', if_cur_ver => '3.1', if_new_ver => '3.2' },
    }
  } ->

  notify { 'Run OpenShift install/config playbook': } ->

  exec { 'Run OpenShift install/config playbook':
    provider => "shell",
    cwd     => "/root/openshift-ansible",
    command => "set -o pipefail; stdbuf -o L ansible-playbook -e \"repoquery_cmd='repoquery --plugins'\" playbooks/byo/config.yml | tee /var/lib/puppet-openshift3/log/ansible-install.log",
    timeout => 1000,
    logoutput => on_failure,
    path      => $::path,
  } ->

  notify { 'Run OpenShift post-install playbook': } ->

  exec { 'Run OpenShift post-install playbook':
    provider => "shell",
    cwd     => "/var/lib/puppet-openshift3/ansible",
    command => "set -o pipefail; ansible-playbook post-install.yml -e 'openshift_package_name=${openshift3::package_name} openshift_component_prefix=${openshift3::component_prefix} openshift_version=${openshift3::version} openshift_major=${openshift3::major} openshift_minor=${openshift3::minor} docker_version=${openshift3::docker_version} vagrant=\"${::vagrant}\" openshift_master_ip=${openshift3::master_ip} http_proxy=${openshift3::http_proxy} https_proxy=${openshift3::https_proxy} no_proxy=${openshift3::no_proxy}' | tee /var/lib/puppet-openshift3/log/ansible-post-install.log",
    timeout => 1000,
    logoutput => on_failure,
    path => $::path,
  } ->

  exec {"Wait for master":
    command => "/usr/bin/wget --spider --tries 60 --retry-connrefused --no-check-certificate https://localhost:8443/",
    unless => "/usr/bin/wget --spider --no-check-certificate https://localhost:8443/",
    path => $::path,
  }
}
