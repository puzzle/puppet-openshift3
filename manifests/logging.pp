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

    new_project { "logging":
      options => '--node-selector=""',
    }

    if $::openshift3::logging_image_version and versioncmp($::openshift3::logging_image_version, "3.3") >= 0 or versioncmp($::openshift3::version, "3.3") >= 0 {
      instantiate_template { "logging-deployer-account-template":
        template_namespace => "openshift",
        resource_namespace => "logging",
        creates => "sa/aggregated-logging-kibana",
        require => New_project["logging"],
        before => New_Secret["logging-deployer"],
        returns => [0, 1],        
      } ->

      add_role_to_user { "system:serviceaccount:logging:logging-deployer":
        role => "oauth-editor",
        role_type => "cluster",
        namespace => "logging",
      } 
    } else {
      new_service_account { "logging-deployer":
        namespace => "logging",
        require => New_project["logging"],
        before => New_Secret["logging-deployer"],
      } ->

      add_role_to_user { "system:serviceaccount:logging:logging-deployer":
        role => "edit",
        namespace => "logging",
      }   
    } ->

    new_secret { "logging-deployer":
      namespace => "logging",
      source => "/dev/null",
      require => Add_Role_To_User["system:serviceaccount:logging:logging-deployer"]
    } ->
    
    add_secret_to_sa { "logging-deployer":
      namespace => "logging",
      service_account => "logging-deployer",
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
      template_parameters => [
        "KIBANA_HOSTNAME=${::openshift3::logging_domain}",
        "KIBANA_OPS_HOSTNAME=${::openshift3::logging_ops_domain}",
        "ES_CLUSTER_SIZE=${::openshift3::logging_cluster_size}",
        "ES_OPS_CLUSTER_SIZE=${::openshift3::logging_ops_cluster_size}",
        "PUBLIC_MASTER_URL=${::openshift3::master_public_api_url}",
        "ES_INSTANCE_RAM=${::openshift3::es_instance_ram}",
        "ES_OPS_INSTANCE_RAM=${::openshift3::es_ops_instance_ram}",
        "ENABLE_OPS_CLUSTER=${::openshift3::enable_ops_logging}",
        "IMAGE_PREFIX=${image_prefix}${image_version}",
      ],
      resource_namespace => "logging",
      creates => "svc/logging-es",
    } ->
    scale_pod { "logging-fluentd":
      namespace => "logging",
      replicas => ready_nodes,
    }

    if $::openshift3::logging_image_version and versioncmp($::openshift3::logging_image_version, "3.3") < 0 or versioncmp($::openshift3::version, "3.3") < 0 {  
      instantiate_template { "logging-support-template":
        template_namespace => "logging",
        resource_namespace => "logging",
        creates => "svc/logging-es",
        require => Scale_Pod['logging-fluentd'],      
      }
    }

    if $::openshift3::enable_ops_logging {
      $volumes = ['-l component=es', '-l component=es-ops']
    } else {
      $volumes = ['-l component=es']
    }

    if $::openshift3::logging_local_storage {
      add_user_to_scc { 'system:serviceaccount:logging:aggregated-logging-elasticsearch':
        scc => 'hostaccess',
      } ->

      set_volume { $volumes:
        namespace => 'logging',
        volume_name => 'elasticsearch-storage',
        host_path => $::openshift3::logging_local_storage,
        require => Scale_Pod['logging-fluentd'],
      }
    } elsif $::openshift3::logging_volume_size {
      set_volume { $volumes:
        namespace => 'logging',
        volume_name => 'elasticsearch-storage',
        claim_name => 'logging-es',
        claim_size => $::openshift3::logging_volume_size,
        claim_instances => $::openshift3::logging_cluster_size,
        require => Scale_Pod['logging-fluentd'],
      }
    }
  }
}
