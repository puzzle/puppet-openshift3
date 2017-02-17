class openshift3::params {
  $deployment_type = "origin"
  $identity_providers = [{
    'name' => 'htpasswd_auth',
    'login' => 'true',
    'challenge' => 'true',
    'kind' => 'HTPasswdPasswordIdentityProvider',
    'filename' => '/etc/origin/master/htpasswd',
  }]
  $app_domain = 'cloudapps.example.com'
  $openshift_dns_bind_addr = undef
  $package_version = undef
  $cluster_network_cidr = '10.1.0.0/16'
  $configure_epel = true
  $epel_repo_id = 'epel'
  $ansible_from_epel = false
  $install_router = true
  $install_registry = true
  $registry_replicas = 1
  $install_logging = true
  $failover_router_interface = undef
  $es_instance_ram = 2G
  $es_ops_instance_ram = 2G
  $enable_ops_logging = false
  $logging_image_version = undef
  $logging_cluster_size = 1
  $logging_ops_cluster_size = 1
  $install_metrics = true
  $setup_monitoring_account = false
  $metrics_image_version = undef
  $metrics_use_persistent_storage = false
  $metrics_pv_size = 20Gi
  $metrics_duration = 3
  $ansible_ssh_user = 'root'
  $ansible_sudo = false
  $ansible_playbook_source = 'https://github.com/openshift/openshift-ansible.git'
  $openshift_ansible_version = 'openshift-ansible-3.4.56-1'
  $set_node_ip = false
  $set_hostname = true
  $docker_options = '-l warn --log-opt max-size=1M --log-opt max-file=3'
  $master_style_repo_ref = 'master'
  $project_request_template = undef
  $project_request_message = undef
  $quota_sync_period = 15s
  $rhsm_repos= ['rhel-7-server-rpms', 'rhel-7-server-extras-rpms', 'rhel-7-server-optional-rpms']
  $run_upgrade_playbooks = true
}
