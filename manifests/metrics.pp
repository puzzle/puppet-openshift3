class openshift3::metrics {

  if versioncmp($::openshift3::version, "3.1") > 0 {
    ensure_resource('file', '/var/lib/puppet-openshift3/certs/metrics', { ensure => directory, mode => 0700 })

    if $::openshift3::deployment_type == "enterprise" {
      $image_prefix = 'registry.access.redhat.com/openshift3/'
    } else {
      $image_prefix = 'openshift/origin-'
    }

    file { "/var/lib/puppet-openshift3/certs/metrics/null":
      content => "",
      owner => root,
      group => root,
      mode => 0600,
      show_diff => false,
    } ->

    new_secret { "metrics-deployer":
      namespace => "openshift-infra",
      source => "/var/lib/puppet-openshift3/certs/metrics",
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

    if $::openshift3::metrics_ssl_cert and $::openshift3::metrics_ssl_key {
      file { "/var/lib/puppet-openshift3/certs/metrics/hawkular-metrics.pem":
        content => "${::openshift3::metrics_ssl_cert}${::openshift3::metrics_ssl_key}",
        owner => root,
        group => root,
        mode => 0600,
        show_diff => false,
        before => New_Secret['metrics-deployer'],
      }
    } else {
      file { "/var/lib/puppet-openshift3/certs/metrics/hawkular-metrics.pem":
        ensure => absent,
        before => New_Secret['metrics-deployer'],
      }
    }

    if $::openshift3::metrics_ca_cert {
      file { "/var/lib/puppet-openshift3/certs/metrics/hawkular-metrics-ca.cert":
        content => $::openshift3::metrics_ca_cert,
        owner => root,
        group => root,
        mode => 0600,
        show_diff => false,
        before => New_Secret['metrics-deployer'],
      }
    } else {
      file { "/var/lib/puppet-openshift3/certs/metrics/hawkular-metrics-ca.cert":
        ensure => absent,
        before => New_Secret['metrics-deployer'],
      }
    }
  }
}
