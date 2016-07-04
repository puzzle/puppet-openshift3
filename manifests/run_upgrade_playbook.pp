define openshift3::run_upgrade_playbook($if_deployment_type, $if_cur_ver, $if_new_ver) {
  $cur_version_arr = split($::openshift_version, '\.')
  $playbook = basename(dirname($title))

  if $::openshift3::deployment_type == $if_deployment_type and $::openshift_version != '' and $::openshift_version != $::openshift3::version and "${cur_version_arr[0]}.${cur_version_arr[1]}" == $if_cur_ver and "${::openshift3::major}.${::openshift3::minor}" == $if_new_ver {
    ensure_resource('file', '/var/lib/puppet-openshift3/playbooks', { ensure => directory })

   notify { "Run ansible playbook $title": } ->

    exec { "Run ansible playbook $title":
      provider => "shell",
      cwd     => "/root/openshift-ansible",
      command => "set -o pipefail; stdbuf -o L ansible-playbook ${title} | tee /var/lib/puppet-openshift3/log/ansible-${playbook}.log",
      timeout => 1000,
      logoutput => on_failure,
      path => $::path,
      require => File['/var/lib/puppet-openshift3/playbooks'],
    }
  }
}
