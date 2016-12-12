define openshift3::run_ansible($cwd, $options = '', $check_options = '', $assert_cluster_version = false) {
  if $assert_cluster_version {
    assert_cluster_version { "Assert cluster version before config playbook":
      before => Exec["Running ansible-playbook $title $options"],
      unless  => "/var/lib/puppet-openshift3/ansible/run-ansible -c $check_options $title $options",
    }
  }

   exec { "Running ansible-playbook $title $options":
    command => "echo Running Ansible playbook $title",
    unless  => "/var/lib/puppet-openshift3/ansible/run-ansible -c $check_options $title $options",
    path => $::path,
  } ->

  exec { "ansible-playbook $title":
    environment => 'HOME=/root',
    cwd     => $cwd,
    command => "/var/lib/puppet-openshift3/ansible/run-ansible $check_options $title $options",
    unless  => "/var/lib/puppet-openshift3/ansible/run-ansible -c $check_options $title $options",
    timeout => 1800,
    logoutput => on_failure,
    path => $::path,
  }
}
