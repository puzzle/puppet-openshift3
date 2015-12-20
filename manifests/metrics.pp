class openshift3::metrics {

  if versioncmp($::openshift3::version, "3.1") > 0 {
    if $::openshift3::deployment_type == "enterprise" {
      $image_prefix = 'registry.access.redhat.com/openshift3/'
    } else {
      $image_prefix = 'openshift/origin-'
    }

    new_secret { "metrics-deployer":
      namespace => "openshift-infra",
      source => "/dev/null",
    } ->
  
    new_service_account { "metrics-deployer":
      namespace => "openshift-infra",
    } ->

    add_secret_to_sa { "metrics-deployer":
      namespace => "openshift-infra",
      service_account => "metrics-deployer",
    } ->

    add_role_to_user { "system:serviceaccount:openshift-infra:metrics-deployer":
      role => "edit",
      namespace => "openshift-infra",
    } ->
    
    add_role_to_user { "system:serviceaccount:openshift-infra:heapster":
      role => "cluster-reader",
      role_type => "cluster",
    } ->

    instantiate_template { "metrics-deployer-template":
      template_namespace => "openshift",
      template_parameters => "HAWKULAR_METRICS_HOSTNAME=metrics.${::openshift3::app_domain},USE_PERSISTENT_STORAGE=false",
      resource_namespace => "openshift-infra",
      creates => "svc/hawkular-metrics",
    }

#    instantiate_template { "logging-support-template":
#      template_namespace => "logging",
#      resource_namespace => "logging",
#      creates => "route/kibana",
#    }

#,IMAGE_PREFIX=${image_prefix}
  }
}
