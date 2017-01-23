Puppet::Type.type(:ansible_module).provide :python do

  desc <<-EOT
    Runs Ansible modules directly using the python executable.
    Does not work with non-Python modules and action plugins, e.g. the debug module.
  EOT
  
  def run()
    resource[:args][:_ansible_check_mode] = resource.noop?
    module_input = {
      :ANSIBLE_MODULE_ARGS => resource[:args]           
    }

    Dir.chdir(resource[:cwd]) do
      module_output, status = Open3.capture2e("python", resource[:module], :stdin_data => module_input.to_json)

      module_output = JSON.parse(module_output)
      changed = module_output['changed']
      output = module_output['msg']

      return changed, output, status
    end
  end
end
