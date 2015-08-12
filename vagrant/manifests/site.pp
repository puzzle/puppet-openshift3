Exec { path => '/sbin:/bin:/usr/sbin:/usr/bin', }

#Package { 
#    allow_virtual => true,
#}

if $::vagrant {
  $_ose_hosts = parsejson($::ose_hosts)
  $master_fqdn = $_ose_hosts[0]['hostname']
} else {
  $master_fqdn = 'victory.rz.puzzle.ch'
}

node 'ose3-master.example.com' {
  include openshift3::master
  include openshift3::node
}

node /ose3-node\d+.example.com/ {
  include openshift3::node
}

node 'origin-master.example.com' {
  include openshift3::master
  include openshift3::node
}

node /origin-node\d+.example.com/ {
  include openshift3::node
}
