define openshift3::yum_versionlock ($ensure = unset, $yum_options = "") {
  ensure_packages('yum-plugin-versionlock')

  $to_envr = 'sed -ne \'s/^package:[ \t]\+\([^ \t]\+\)\.\([^ \t]\+\)[ \t]\+\([^ \t]\+\).*/\1-\3/p\''
  $get_envr = "export envr=`yum -q deplist --disableplugin=versionlock ${yum_options} ${title}-${ensure} | head -1 | ${to_envr}`"

  exec { "yum_versionlock $title":
    provider => 'shell',
    command => "${get_envr}; yum versionlock delete ${title}; yum ${yum_options} versionlock \${envr}; yum versionlock list -q | grep -q \${envr}",
    unless => "${get_envr}; yum versionlock list -q | grep -q \${envr}",
    logoutput => on_failure,
    path => $::path,
    require => Package['yum-plugin-versionlock'],
  }
}
