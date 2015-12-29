define openshift3::proxy_shellvars ($file = $title, $http_proxy, $https_proxy, $no_proxy) {

  if $https_proxy {
    $real_https_proxy = $https_proxy
  } else {
    $real_https_proxy = $http_proxy
  }  

  if $http_proxy {
    augeas { "Set proxy in ${file}":
      changes => [
        "set /files${file}/http_proxy ${http_proxy}",
        "set /files${file}/https_proxy ${real_https_proxy}",
        "set /files${file}/no_proxy ${no_proxy}",
      ],
    }
  } else {
    augeas { "Remove proxy from ${file}":
      changes => [
        "rm /files${file}/http_proxy ${http_proxy}",
        "rm /files${file}/https_proxy ${real_https_proxy}",
        "rm /files${file}/no_proxy ${no_proxy}",
      ],
    }
  }
}
