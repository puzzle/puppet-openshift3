#!/usr/bin/python

#import json
#import pprint
#import jsonpath_rw_ext

def main():
    module = AnsibleModule(
        argument_spec=dict(
            state = dict(default='present', choices=['present', 'absent']),
            name = dict(type='str'),
        ),
        supports_check_mode=True
    )

    state = module.params['state']
    name = module.params['name']

    (rc, stdout, stderr) = module.run_command('oc get project ' + name)

    if (rc == 0) == (state == 'present'):
      module.exit_json(changed=False)

    if state == 'present':
      cmd = 'oc new-project'
    else:
      cmd = 'oc delete-project'

    args = cmd + ' ' + name
    if not module.check_mode:
      module.run_command(args, check_rc=True)

    module.exit_json(changed=True, msg=args)


from ansible.module_utils.basic import *
if __name__ == "__main__":
    main()
