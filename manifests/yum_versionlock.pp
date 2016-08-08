define openshift3::yum_versionlock ($ensure = unset, $yum_options = "") {
  ensure_packages('yum-plugin-versionlock')

  exec { "yum_versionlock $title":
    provider => 'shell',
    command => "yum versionlock delete ${title}; yum ${yum_options} versionlock ${title}-${ensure}; yum versionlock list | grep -q :${title}-${ensure}",
    unless => "yum versionlock list | grep -q :${title}-${ensure}",
    logoutput => on_failure,
    path => $::path,
    require => Package['yum-plugin-versionlock'],
  }
}
