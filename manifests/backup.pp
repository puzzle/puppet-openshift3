class openshift3::etcd_backup {
  if $::openshift3::enable_etcd_backup {
    cron { 'etcd_backup':
      command => '/usr/bin/etcdctl backup --data-dir ${::openshift3::etcd_data_dir} --backup-dir ${::openshift3::etcd_backup_dir}',
      user    => 'root',
      hour    => $::openshift3::etcd_backup_hour,
      minute  => $::openshift3::etcd_backup_minute,
    }
  }
}



FIXME: It should be possible to define $::openshift3::etcd::pre_backup_script somewhere.

file { "$::openshift3::etcd::pre_backup_script":
  content   => template("openshift3/openshift/backup_etcd.sh.erb"),
  owner     => "root",
  group     => "root",
  mode      => 644,
  show_diff => no,
}



define openshift3::backup_etcd () {
  exec { "new project ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oadm new-project ${title}",
    unless      => "oc get project ${title}",
    timeout     => 60,
    path        => $::path,
  }
}
