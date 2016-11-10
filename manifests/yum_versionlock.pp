define openshift3::yum_versionlock ($ensure = unset, $yum_options = "") {
  ensure_packages('yum-plugin-versionlock')

  exec { "yum_versionlock $title":
    provider => 'shell',
    command => "export nvr=`repoquery --plugins --setopt=disableplugins=versionlock --queryformat '%{nvr}' ${yum_options} ${title}-${ensure}`; yum versionlock delete ${title}; yum ${yum_options} versionlock \${nvr}; yum versionlock list -q | grep -q :\${nvr}",
    unless => "export nvr=`repoquery --plugins --setopt=disableplugins=versionlock --queryformat '%{nvr}' ${yum_options} ${title}-${ensure}`; yum versionlock list -q | grep -q :\${nvr}",
    logoutput => on_failure,
    path => $::path,
    require => Package['yum-plugin-versionlock'],
  }
}
