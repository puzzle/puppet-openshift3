class openshift3::monitoring {
  if $::openshift3::setup_monitoring_account and versioncmp($::openshift3::version, "3.1") > 0 {
    $_ns = 'monitoring-infra'

    new_project { $_ns: } ->
    new_service_account { "monitoring":
      namespace => $_ns,
    } ->
    add_role_to_user { "system:serviceaccount:${_ns}:monitoring":
      namespace => $_ns,
      role_type => "cluster",
      role => "view",
    } ->
    new_service_account { "endtoend":
      namespace => $_ns,
    }
  }
}
