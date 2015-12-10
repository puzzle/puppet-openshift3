define openshift3::run_upgrade_playbook($deployment_type, $match_versions) {
  $playbook = regsubst($title, "/", "_", "G")
#  $matched_version = inline_template('<%= matchData = scope["::openshift3::version"].match(/^#{@match_versions}$/); matchData ? matchData[1] : nil %>')
  $matched_version = inline_template('<%= matchData = scope["::openshift3::version"].match("^#{@match_versions}$"); matchData ? matchData[1] : nil %>')

  if $matched_version {
    ensure_resource('file', '/var/lib/puppet-openshift3/playbooks', { ensure => directory })

    exec { "Run ansible playbook $title":
      cwd     => "/root/openshift-ansible",
      command => "ansible-playbook ${title} && touch /var/lib/puppet-openshift3/playbooks/${playbook}-${matched_version}",
      unless => "[ '${::openshift3::deployment_type}' != '${deployment_type}' ] || [ -e '/var/lib/puppet-openshift3/playbooks/${playbook}-${matched_version}' ] ",
      timeout => 1000,
      logoutput => on_failure,
      require => File['/var/lib/puppet-openshift3/playbooks'],
    }
  }
}
