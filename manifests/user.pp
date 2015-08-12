class openshift3::user {
  if $::vagrant {
    user { ['joe', 'alice' ]:
      ensure => present,
      managehome => true,
    } ->

    htpasswd { ['joe', 'alice']:
      cryptpasswd => '$apr1$LB4KhoUd$2QRUqJTtbFnDeal80WI2R/',
      target      => '/etc/openshift/openshift-passwd',
    }
  }
}
