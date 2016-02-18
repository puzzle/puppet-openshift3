Exec { path => '/sbin:/bin:/usr/sbin:/usr/bin', }

#Package { 
#    allow_virtual => true,
#}

node 'ose3-master.example.com' {
  include openshift3::master
}

node /ose3-node\d+.example.com/ {
#  include openshift3::node
}

node 'origin-master.example.com' {
  include openshift3::master
}

node /origin-node\d+.example.com/ {
#  include openshift3::node
}

node default {
}
