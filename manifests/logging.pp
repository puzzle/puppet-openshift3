class openshift3::logging {
  if $::openshift3::install_logging and versioncmp($::openshift3::version, "3.1") > 0 {
    if $::openshift3::deployment_type == "enterprise" {
      $image_prefix = 'registry.access.redhat.com/openshift3/'
    } else {
      $image_prefix = 'openshift/origin-'
    }

    if $::openshift3::logging_image_version {
      $image_version = ",IMAGE_VERSION=${::openshift3::logging_image_version}"
    } else {
      $image_version = ""
    }

    new_project { "logging": } ->

    new_secret { "logging-deployer":
      namespace => "logging",
      source => "/dev/null",
    } ->
  
    new_service_account { "logging-deployer":
      namespace => "logging",
    } ->

    add_secret_to_sa { "logging-deployer":
      namespace => "logging",
      service_account => "logging-deployer",
    } ->

    add_role_to_user { "system:serviceaccount:logging:logging-deployer":
      role => "edit",
      namespace => "logging",
    } ->
    
    add_user_to_scc { "system:serviceaccount:logging:aggregated-logging-fluentd":
      scc => "privileged",
    } ->
  
    add_role_to_user { "system:serviceaccount:logging:aggregated-logging-fluentd":
      role => "cluster-reader",
      role_type => "cluster",
    } ->

    instantiate_template { "logging-deployer-template":
      template_namespace => "openshift",
      template_parameters => "KIBANA_HOSTNAME=${::openshift3::logging_domain},KIBANA_OPS_HOSTNAME=${::openshift3::logging_ops_domain},ES_CLUSTER_SIZE=1,ES_OPS_CLUSTER_SIZE=1,PUBLIC_MASTER_URL=${::openshift3::master_public_api_url},ES_INSTANCE_RAM=${::openshift3::es_instance_ram},ES_OPS_INSTANCE_RAM=${::openshift3::es_ops_instance_ram},ENABLE_OPS_CLUSTER=${::openshift3::enable_ops_logging},IMAGE_PREFIX=${image_prefix}${image_version}",
      resource_namespace => "logging",
      creates => "svc/logging-es",
    } ->

    scale_pod { "logging-fluentd":
      namespace => "logging",
      replicas => ready_nodes,
    } ->

    instantiate_template { "logging-support-template":
      template_namespace => "logging",
      resource_namespace => "logging",
      creates => "svc/logging-es",
    }

    if $::openshift3::enable_ops_logging {
      $volumes = ['-l component=es', '-l component=es-ops']
    } else {
      $volumes = ['-l component=es']
    }

    if $::openshift3::logging_local_storage {
      set_volume { $volumes:
        namespace => 'logging',
        volume_name => 'elasticsearch-storage',
        host_path => $::openshift3::logging_local_storage,
        require => Instantiate_Template["logging-support-template"],
      }
    } elsif $::openshift3::logging_volume_size {
      set_volume { $volumes:
        namespace => 'logging',
        volume_name => 'elasticsearch-storage',
        claim_name => 'elasticsearch-storage',
        claim_size => $::openshift3::logging_volume_size,
        require => Instantiate_Template["logging-support-template"],
      }
    }
  }
}
