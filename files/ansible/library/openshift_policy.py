#!/usr/bin/python

import json
#import jsonpath_rw_ext

def update_policy(module, roleBindings, cluster_role, principal_type, principals, changed, msg):    
  state = module.params['state']

  cmd = 'oadm policy '
  if state == 'present':
    cmd += 'add-cluster-role-to-' + principal_type
  else:
    cmd += 'remove-cluster-role-from-' + principal_type

  changedPrincipals = []
  for principal in principals:
    roleBinding = [rb for rb in roleBindings['items'] if rb['roleRef']['name'] == cluster_role and rb[principal_type + 'Names'] and principal in rb[principal_type + 'Names']]
    if bool(roleBinding) != (state == 'present'):
      changedPrincipals.append(principal)

  if changedPrincipals:
    changed = True
    args = cmd + " " + cluster_role + " " + " ".join(changedPrincipals)
    msg += args + "; "
    if not module.check_mode:
      (rc, stdout, stderr) = module.run_command(args, check_rc=True)
          
  return (changed, msg)
  

def main():
    module = AnsibleModule(
        argument_spec=dict(
            state = dict(default='present', choices=['present', 'absent']),
            cluster_roles  = dict(type='list'),
            groups = dict(type='list'),
            users = dict(type='list'),
        ),
        supports_check_mode=True
    )

    cluster_roles = module.params['cluster_roles']
    groups = module.params['groups']
    users = module.params['users']

    (rc, stdout, stderr) = module.run_command('oc get clusterrolebinding -o json', check_rc=True)
    roleBindings = json.loads(stdout)

    changed = False
    msg = ''

    #if not isinstance(cluster_roles, list):
    #  cluster_roles = [cluster_roles]

    for cluster_role in cluster_roles or []:      
      if groups:
        (changed, msg) = update_policy(module, roleBindings, cluster_role, 'group', groups, changed, msg)

      if users:
        (changed, msg) = update_policy(module, roleBindings, cluster_role, 'user', users, changed, msg)

#      jsonpath = jsonpath_rw_ext.parse('$.items[?(@.roleRef.name == "%s")].userNames[?(@ == "%s")]' % (cluster_role, user))
#      if (len(jsonpath.find(roleBindings)) > 0) != (state == 'present'):
#        changed = True
#        args = cmd + " " + cluster_role + " " + user
#        msg += args + "; "
#        if not module.check_mode:
#          (rc, stdout, stderr) = module.run_command(args, check_rc=True)
 
    module.exit_json(changed=changed, msg=msg)


from ansible.module_utils.basic import *
if __name__ == "__main__":
    main()
