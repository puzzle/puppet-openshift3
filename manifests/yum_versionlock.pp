define openshift3::yum_versionlock ($ensure = unset, $yum_options = "") {
  ensure_packages('yum-plugin-versionlock')

  $to_envr = 'sed -ne \'s/^package:[ \t]\+\([^ \t]\+\)\.\([^ \t]\+\)[ \t]\+\([^ \t]\+\).*/\1-\3/p\''
  $get_envr = "export envr=`yum -q -C deplist --disableplugin=versionlock ${yum_options} ${title}-${ensure} | head -1 | ${to_envr}`"

  exec { "yum_versionlock $title":
    provider => 'shell',
    command => "${get_envr}; yum -C versionlock delete ${title}; yum -C ${yum_options} versionlock \${envr}; yum -C versionlock list -q | grep -q \${envr}",
    unless => "yum makecache fast; ${get_envr}; yum -C versionlock list -q | grep -q \${envr}",
    logoutput => on_failure,
    path => $::path,
    require => Package['yum-plugin-versionlock'],
  }
}
