class openshift3::logging {

  if versioncmp($::openshift3::version, "3.1") > 0 {
    if $::openshift3::deployment_type == "enterprise" {
      $image_prefix = 'registry.access.redhat.com/openshift3/'
    } else {
      $image_prefix = 'openshift/origin-'
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
      template_parameters => "KIBANA_HOSTNAME=logging.${::openshift3::app_domain},KIBANA_OPS_HOSTNAME=logging-ops.${::openshift3::app_domain},ES_CLUSTER_SIZE=1,ES_OPS_CLUSTER_SIZE=1,PUBLIC_MASTER_URL=https://${::openshift3::master}:8443,ES_INSTANCE_RAM=${::openshift3::es_instance_ram},ES_OPS_INSTANCE_RAM=${::openshift3::es_ops_instance_ram},ENABLE_OPS_CLUSTER=${::openshift3::enable_ops_logging},IMAGE_PREFIX=${image_prefix}",
      resource_namespace => "logging",
      creates => "svc/logging-es",
    } ->

    set_volume { ['component=es', 'component=es-ops']:
      namespace => 'logging',
      volume_name => 'elasticsearch-storage',
      claim_name => 'elasticsearch-storage',
      claim_size => $::openshift3::,
    } ->

    scale_pod { "logging-fluentd":
      namespace => "logging",
      replicas => ready_nodes,
    } ->

    instantiate_template { "logging-support-template":
      template_namespace => "logging",
      resource_namespace => "logging",
      creates => "route/kibana",
    }
  }
}
