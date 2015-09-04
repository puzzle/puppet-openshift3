class openshift3::ssh-keys {
  if $::vagrant {
    file { '/root/.ssh':
      ensure  => directory,
      owner  => 'root',
      group  => 'root',
      mode   => 0700,
    }

    file { '/root/.ssh/id_rsa.pub':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      source => '/vagrant/.ssh/id_rsa.pub',
    }

    file { '/root/.ssh/id_rsa':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      source => '/vagrant/.ssh/id_rsa',
    }

    ssh_authorized_key { "${::openshift3::ssh_key[name]}":
      user => 'root',
      type => $::openshift3::ssh_key[type],
      key  => $::openshift3::ssh_key[key],
    }
  }
}
