define openshift3::oc_replace ($expression = $title, $namespace = 'default', $resource = undef, $unless = undef, $refreshonly = undef, $logoutput = false) {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt =""
  }

  if $resource {
    case $expression {
      /^([0-9a-zA-Z_.\[\]]+)\s*=\s*(-?[0-9]+|".+"|\{.+\}|true|false)$/:            { $condition = "$1 == $2" }
      /^([0-9a-zA-Z_.\[\]]+)\s*\+=\s*(\[-?[0-9]+\]|\["[^"]+"\])$/:  { $condition = "$1 | contains($2)" }
      default:                                                { fail("Unsupported expression: $expression") }
    }

    exec { "oc_replace $resource $expression":
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => "oc get ${namespace_opt} ${resource} -o json | jq '$expression' | oc update ${namespace_opt} -f -",
      unless => "oc get ${namespace_opt} ${resource} -o json | [ `jq '$condition'` == true ]",
      timeout => 600,
      refreshonly => $refreshonly,
      logoutput => $logoutput,
      path => $::path,
    }
  } else {
    ensure_resource('file', '/var/lib/puppet-openshift3/examples', { ensure => directory })

    if $expression =~ /\/$/ {
      $files = "${expression}*"
    } else {
      $files = $expression
    }

    exec { "oc_replace $expression":
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => "oc create ${namespace_opt} -f '${expression}'; oc update ${namespace_opt} -f '${expression}' && sha1sum ${files} >/var/lib/puppet-openshift3/examples/`basename '${expression}'`.sha1sum",
      unless => "sha1sum -c /var/lib/puppet-openshift3/examples/`basename '${$expression}'`.sha1sum",
      timeout => 600,
      refreshonly => $refreshonly,
      logoutput => $logoutput,
      path => $::path,
      require => File['/var/lib/puppet-openshift3/examples'],
    }
  }
}
