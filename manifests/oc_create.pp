define openshift3::oc_create ($namespace = 'default', $resource = undef, $unless = undef, $refreshonly = undef, $returns = undef, $logoutput = false) {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt = ""
  }

#  if $resource {
#    case $title {
 #     /^([0-9a-zA-Z_.\[\]]+)\s*=\s*(-?[0-9]+|".+"|{.+}|true|false)$/:            { $condition = "$1 == $2" }
 #     /^([0-9a-zA-Z_.\[\]]+)\s*\+=\s*(\[-?[0-9]+\]|\["[^"]+"\])$/:  { $condition = "$1 | contains($2)" }
 #     default:                                                { fail("Unsupported expression: $title") }
 #   }

#      unless => "oc get ${namespace_opt} '${resource}' -o json | [ `jq '$condition'` == true ]",

    exec { "oc_create $title":
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => "oc create ${namespace_opt} -f '${title}'",
      unless => $unless,
      timeout => 600,
      refreshonly => $refreshonly,
      returns => $returns,
      logoutput => $logoutput,
    }
#  } else {
#    exec { "oc_replace $title":
#      provider => 'shell',
#      environment => 'HOME=/root',
#      cwd     => "/root",
#      command => "oc update ${namespace_opt} -f '${title}'",
#      unless => $unless,
#      timeout => 600,
#      refreshonly => $refreshonly,
#      logoutput => $logoutput,
#    }
#  }
}
