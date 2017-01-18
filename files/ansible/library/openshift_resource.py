#!/usr/bin/python

import json
from StringIO import StringIO
import tempfile
import re
import logging

DOCUMENTATION = '''
---
module: openshift_resource
short_description: Creates and patches OpenShift resources
options:
    gather_subset:
        description:
            - "if supplied, restrict the additional facts collected to the given subset.
              Possible values: all, hardware, network, virtual, ohai, and
              facter Can specify a list of values to specify a larger subset.
              Values can also be used with an initial C(!) to specify that
              that specific subset should not be collected.  For instance:
              !hardware, !network, !virtual, !ohai, !facter.  Note that a few
              facts are always collected.  Use the filter parameter if you do
              not want to display those."
        required: false
        default: 'all'
'''

class ResourceModule:
  def __init__(self, module):
    self.module = module

    self.changed = False
    self.msg = []
    self.arguments = []
    
    for key in module.params:
      setattr(self, key, module.params[key])

  def exemption(self, kind, current, patch, path):
    if patch is None or isinstance(patch, (dict, list)) and not patch:
      return True
    elif kind == 'DeploymentConfig' and re.match('.spec.template.spec.containers\[[0-9]+\].image', path):
      image = patch.split(':')[0]
      return ("/" + image + "@") in current

    return False


  def patch_applied(self, kind, name, current, patch, path = ""):
    logging.debug(path)
    if current is None:
      if not patch is None:
        self.msg.append(self.namespace + "::" + kind + "/" + name + "{" + path + "}(" + str(patch) + " != " + str(current) + ")")
        return False
    elif isinstance(patch, dict):
      for key, val in patch.iteritems():      
        if not self.patch_applied(kind, name, current.get(key), val, path + "." + key):
          return False
    elif isinstance(patch, list):
      if not self.sublist(kind, name, current, patch, path):
        return False
    else:
      if current != patch and not self.exemption(kind, current, patch, path):
        self.msg.append(self.namespace + "::" + kind + "/" + name + "{" + path + "}(" + str(patch) + " != " + str(current) + ")")
        return False

    return True


  def equalList(self, kind, resource, current, patch, path):
    """Compare two lists recursively."""
    if len(current) != len(patch):
      self.msg.append(self.namespace + "::" + kind + "/" + resource + "{" + path + "}(length mismatch)")
      return False

    for i, val in enumerate(patch):
        if not self.patch_applied(kind, resource, current[i], val, path + "[" + str(i) + "]"):
          return False

    return True


  def sublist(self, kind, name, current, patch, path):
    if not current and not patch:
      return True
    elif not current:
      self.msg.append(self.namespace + "::" + kind + "/" + name + "{" + path + "}(new)")
      return False
    elif isinstance(current[0], dict) and 'name' in current[0]:
      for i, patchVal in enumerate(patch):
        elementName = patchVal.get('name')
        if elementName is None:  # Patch contains element without name attribute => fall back to plain list comparison.
          logging.debug("Patch contains element without name attribute => fall back to plain list comparison.")
          return self.equalList(kind, name, current, patch, path)
        curVals = [curVal for curVal in current if curVal.get('name') == elementName]
        if len(curVals) == 0:
           self.msg.append(self.namespace + "::" + kind + "/" + name + "{" + path + '[' + str(len(current)) + ']' + "}(new)")
           return False
        elif len(curVals) == 1: 
          if not self.patch_applied(kind, name, curVals[0], patchVal, path + '[' + str(i) + ']'):
            return False
        else:
          module.fail_json(msg="Patch contains multiple attributes with name '" + elementName + "' under path: " + path)      

    return True


#local_action:
#    module: openshift_resource
#    namespace: openshift-infra
#    deployer: metrics-deployer-template
#    deployer_namespace: openshift
#    arguments:
#      HAWKULAR_METRICS_HOSTNAME: "{{openshift3_metrics_domain}}"
#    deploy_unless:
#      - kind: rc
#        label: metrics-infra=hawkular-cassandra
#        patch:


#  def patch_applied(self, namespace, kind, name, current, patch, path = ""):

  def run_deployer(self):
    logging.debug("run_deployer " + str(self.deployer) + " " + str(self.arguments))
    #deploy_needed = False
    #for cond in self.deploy_unless:
    #  current = self.get_resource(kind, label=self.label)
    #  if not self.patch_applied(self.kind, self.label, current, self.patch):
    #    deploy_needed = True
    #    break
    
    #if deploy_needed:
    self.apply_template(self.deployer, self.arguments)

    #return changed


  def export_resource(self, kind, name = None, label = None):
    if label:
      name = '-l ' + label

    (rc, stdout, stderr) = self.module.run_command(['oc', 'export', '-n', self.namespace, kind + '/' + name, '-o', 'json'])

    if rc == 0:
      result = json.load(StringIO(stdout))
    else:
      result = {}

    return result
  
  def patch_resource(self, kind, name, patch):
    (rc, stdout, stderr) = self.module.run_command(['oc', 'patch', '-n', self.namespace, kind + '/' + name, '-p', json.dumps(patch)], check_rc=True)

  def update_resource(self, kind, name, object):
    logging.debug("update_resource " + str(kind) + " " + str(name))
    current = self.export_resource(kind, name)

    if not current:
      self.changed = True
      self.msg.append(self.namespace + "::" + kind + "/" + name + "(new)")
      file = tempfile.NamedTemporaryFile(prefix=kind + '_' + name, delete=True)
      json.dump(object, file)
      file.flush()
      (rc, stdout, stderr) = self.module.run_command(['oc', 'create', '-n', self.namespace, '-f', file.name], check_rc=True)
      file.close()
    elif not self.patch_applied(kind, name, current, object):
      self.changed = True
      self.patch_resource(kind, name, object)

    return self.changed

  def process_template(self, template_name, arguments):
    if arguments:
      args = " -p " + ",".join("=".join(_) for _ in arguments.items())
    else:
      args = ""

    if self.app_name:
      args += ' --name=' + self.app_name

    (rc, stdout, stderr) = self.module.run_command('oc new-app -o json ' + template_name + args, check_rc=True)

    if stderr:
      self.module.fail_json(msg=stderr)

    return json.load(StringIO(stdout))

  def apply_template(self, template_name, arguments):    
    template = self.process_template(template_name, arguments)

    for object in template['items']:    
      self.update_resource(object['kind'], object['metadata']['name'], object)
#     msg += object['kind'] + '/' + object['metadata']['name'] + "; "
#      msg += json.dumps(object) + "; "

def main():
    logging.basicConfig(filename='/var/lib/puppet-openshift3/log/openshift_resource.log', level=logging.INFO)

    module = AnsibleModule(
        argument_spec=dict(
            namespace = dict(type='str'),
            template = dict(type='str'),
            app_name = dict(type='str'),
            arguments = dict(type='dict'),
            patch = dict(type='dict'),
            name = dict(type='str'),
            deployer = dict(type='str'),
            deployer_namespace = dict(type='str'),
            deploy_unless = dict(type='list'),
            type = dict(type='str'),
            selector = dict(type='str'),            
        ),
        supports_check_mode=True
    )
    
    resource = ResourceModule(module)

    if resource.template:
      resource.apply_template(resource.template, resource.arguments)
    elif resource.deployer:
      resource.run_deployer()
#      try:
#        parsed_patch = json.load(StringIO(patch))
#      except Exception as e:
#        with open('/tmp/patch', 'w') as f:
#          f.write(patch)
#        module.fail_json(msg="Failed to parse patch: " + str(e) + "\n" + patch)
    else:        
      resource.update_resource(resource.type, resource.name, resource.patch)

    module.exit_json(changed=resource.changed, msg=" ".join(resource.msg))


from ansible.module_utils.basic import *
if __name__ == "__main__":
    main()

