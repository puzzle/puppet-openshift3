define openshift3::assert_cluster_version($unless) {
  #$get_cluster_version = '$(kubectl version|sed -ne \'s/Server\ Version.*Major:"\([^"]\+\)".*Minor:"\([^"]\+\).*/\1.\2/p\')'
  $get_cluster_version = '$(ansible masters[0] -m shell -a "openshift version 2>/dev/null" | sed -ne \'s/openshift \+v\?\([0-9.]\+\).*/\1/p\')'
  $configured_version = "${::openshift3::version}"

  exec { $title:
    provider  => "shell",
    environment => 'HOME=/root',    
    command   => "cluster_version=${get_cluster_version}; \
                [ -z \"\${cluster_version}\" ] || [ \"\${cluster_version}\" = \"${configured_version}\" ] || \
                { echo \"Cluster version \${cluster_version} doesn't match configured version ${configured_version}, upgrade playbook disabled or not registered in ansible.pp?\" >&2; exit 1; }",
    unless    => $unless, 
    logoutput => on_failure,
    path      => $::path,
  }
}
