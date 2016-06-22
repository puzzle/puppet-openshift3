define openshift3::run_ansible($cwd, $options = '') {
  notify { "Run ansible playbook $title if needed": } ->

  exec { "Run ansible playbook $title":
    cwd     => $cwd,
    command => "/var/lib/puppet-openshift3/ansible/run-ansible $title $options",
    unless  => "/var/lib/puppet-openshift3/ansible/run-ansible -c $title $options",
    timeout => 1000,
    logoutput => on_failure,
    path => $::path,
  }
}
