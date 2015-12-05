define openshift3::add_user_to_scc ($namespace = 'default', $scc = undef) {
  oc_replace { ".users += [\"${title}\"]":
    resource => "scc/${scc}",
  }
}
