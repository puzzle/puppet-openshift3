define openshift3::yum_versionlock ($ensure = unset, $yum_options = "") {
  ensure_packages('yum-plugin-versionlock')

  $nvr = inline_template("<%= `repoquery --queryformat '%{nvr}' ${yum_options} ${title}-${ensure}`.chomp %>")

  exec { "yum_versionlock $title":
    provider => 'shell',
    command => "yum versionlock delete ${title}; yum ${yum_options} versionlock ${nvr}; yum versionlock list -q | grep -q ':${nvr}'",
    unless => "yum versionlock list -q | grep -q :${nvr}",
    logoutput => on_failure,
    path => $::path,
    require => Package['yum-plugin-versionlock'],
  }
}
