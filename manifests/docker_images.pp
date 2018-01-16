class openshift3::docker_images {

#  if $::vagrant {
#    exec { 'Import docker images':
#      cwd     => "/vagrant",
#      command => "/vagrant/puppet/import-docker",
#      creates => "/.docker_imported",
#      timeout => 1000,
#      require => Exec['Run ansible'],
#    } -> Docker::Image <| |>
#  }

  docker::image { [
    "${::openshift3::component_prefix}-deployer",
    "${::openshift3::component_prefix}-pod",
    "${::openshift3::component_prefix}-haproxy-router",
    "${::openshift3::component_prefix}-docker-registry",
    "${::openshift3::component_prefix}-docker-builder",
    "${::openshift3::component_prefix}-sti-builder",
    ]:
    image_tag => "v${::openshift3::version}",
  }
}
