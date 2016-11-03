#!/usr/bin/python

import json
from StringIO import StringIO
import tempfile
import re

def exemption(namespace, kind, name, current, patch, msg, path):
  if kind == 'DeploymentConfig' and re.match('.spec.template.spec.containers\[[0-9]+\].image', path):
    image = patch.split(':')[0]
    return ("/" + image + "@") in current
    
  return False


def equalList(namespace, kind, resource, current, patch, msg, path):
  if len(current) != len(patch):
    msg.append(namespace + "::" + kind + "/" + resource + "{" + path + "}(length mismatch)")
    return False

  for i, val in enumerate(patch):
      if not patch_applied(module, namespace, kind, resource, current[i], val, msg, path + "[" + str(i) + "]"):
        return False

  return True

def sublist(module, namespace, kind, resource, current, patch, msg, path):
  if not current:
    msg.append(namespace + "::" + kind + "/" + resource + "{" + path + "}(new)")
    return False
  
  if isinstance(current[0], dict) and 'name' in current[0]:
    for i, patchVal in enumerate(patch):
      name = patchVal.get('name')
      if name is None:  # Patch contains element without name attribute => fall back to plain list comparison.
        return equalList(namespace, kind, resource, current, patch, msg, path)
      curVals = [curVal for curVal in current if curVal.get('name') == name]
      if len(curVals) == 1: 
        if not patch_applied(module, namespace, kind, resource, curVals[0], patchVal, msg, path + '[' + str(i) + ']'):
          return False
      elif len(curVals) > 1:
        module.fail_json(msg="Patch contains multiple attributes with name '" + name + "' under path: " + path)      

  return True

def patch_applied(module, namespace, kind, name, current, patch, msg, path = ""):
  if isinstance(patch, dict):
    for key, val in patch.iteritems():      
      if not patch_applied(module, namespace, kind, name, current.get(key), val, msg, path + "." + key):
        return False
  elif isinstance(patch, list):
    if not sublist(module, namespace, kind, name, current, patch, msg, path):
      return False
  else:
    if current != patch and not exemption(namespace, kind, name, current, patch, msg, path):
      msg.append(namespace + "::" + kind + "/" + name + "{" + path + "}(" + str(patch) + " != " + str(current) + ")")
      return False

  return True

def update_resource(module, namespace, resource, object, changed, msg):
  (rc, stdout, stderr) = module.run_command('oc export -n ' + namespace + ' ' + resource + ' -o json')
  if rc == 0:
    current = json.load(StringIO(stdout))
  else:
    current = {}

  (kind, name) = resource.split('/')
  if not current:
    changed = True
    msg.append(namespace + "::" + resource + "(new)")
    file = tempfile.NamedTemporaryFile(prefix=kind + '_' + name, delete=True)
    json.dump(object, file)
    file.flush()
    (rc, stdout, stderr) = module.run_command(['oc', 'create', '-n', namespace, '-f', file.name], check_rc=True)
    file.close()
  elif not patch_applied(module, namespace, kind, name, current, object, msg):
    changed = True
    (rc, stdout, stderr) = module.run_command(['oc', 'patch', '-n', namespace, resource, '-p', json.dumps(object)], check_rc=True)

  return changed

def process_template(module, namespace, template_name, arguments, changed, msg):
    if arguments:
      args = " ".join("=".join(_) for _ in arguments.items())
    else:
      args = ""

    (rc, stdout, stderr) = module.run_command('oc process -f ' + template_name + ' ' + args, check_rc=True)
    if stderr:
      module.fail_json(msg=stderr)

    template = json.load(StringIO(stdout))

    for object in template['items']:
      resource = object['kind'] + '/' + object['metadata']['name']
      changed = update_resource(module, namespace, resource, object, changed, msg)

    return changed

def main():
    module = AnsibleModule(
        argument_spec=dict(
            namespace = dict(type='str'),
            template = dict(type='str'),
            arguments = dict(type='dict'),
            patch = dict(type='dict'),
            resource = dict(type='str'),
        ),
        supports_check_mode=True
    )

    namespace = module.params['namespace']
    template_name = module.params['template']
    arguments = module.params['arguments']
    patch = module.params['patch']
    resource = module.params['resource']
    
    changed = False
    msg = []

    if template_name:
      changed = process_template(module, namespace, template_name, arguments, changed, msg)
    else:
      changed = update_resource(module, namespace, resource, patch, changed, msg)

    module.exit_json(changed=changed, msg=" ".join(msg))


from ansible.module_utils.basic import *
if __name__ == "__main__":
    main()

