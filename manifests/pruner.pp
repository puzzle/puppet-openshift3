class openshift3::pruner {

  ensure_resource('file', '/home/pruner/bin', { ensure => directory })

  file { '/home/pruner/bin/prune.sh':
    path    => '/home/pruner/bin/prune.sh',
    ensure  => file,
    content => template("openshift3/openshift/prune.sh.erb"),
    mode    => '0755',
    owner   => 'pruner',
    group   => 'pruner',
  } ->

  cron { 'Hourly OpenShift prune job':
    command => '/home/pruner/bin/prune.sh > /dev/null',
    user    => pruner,
    minute  => 0,
  } ->

  # add htpasswd_auth part, usually in hiera


  # prune user has to login first or else OpenShift won't know him


  add_role_to_user { "pruner":
    role => "edit",
    role_type => "cluster",
  }
}

