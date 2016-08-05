define openshift3::run_ansible($cwd, $options = '', $check_options = '') {
  exec { "Running ansible-playbook $title $options":
    command => "echo Running Ansible playbook $title",
    unless  => "/var/lib/puppet-openshift3/ansible/run-ansible -c $check_options $title $options",
    path => $::path,
  } ->

  exec { "ansible-playbook $title":
    cwd     => $cwd,
    command => "/var/lib/puppet-openshift3/ansible/run-ansible $check_options $title $options",
    unless  => "/var/lib/puppet-openshift3/ansible/run-ansible -c $check_options $title $options",
    timeout => 1000,
    logoutput => on_failure,
    path => $::path,
  }
}
