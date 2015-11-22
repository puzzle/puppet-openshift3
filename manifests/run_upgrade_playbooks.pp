define openshift3::run_upgrade_playbooks($playbooks) {
  create_resources(run_upgrade_playbook, $playbooks)
}
