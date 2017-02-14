Puppet::Type.newtype(:ansible_module) do

  @doc = %q{Run a single Ansible module.

    Example:

        ansible_module { 'Set timezone of Docker registry':
          cwd    => get_module_path($module_name),
          module => 'files/ansible/library/openshift_resource.py',
          args   => {
            namespace => 'default',
            type      => 'dc',
            name      => 'docker-registry',
            patch     => parseyaml('
              spec:
                template:
                  spec:
                    containers:
                    - name: registry
                      env:
                      - name: TZ
                        value: "Europe/Zurich"'),
          }
        }
  }


  newparam(:title) do
    isnamevar
    desc "Unique resource title."
  end

  newparam(:cwd) do
    desc "Existing directory to change to before running the Ansible module."

    defaultto "."
  end

  newparam(:module) do
    desc "Path of the Ansible module. Can either be absolute or relative to *cwd*."
  end

  newproperty(:args) do |property|
    desc "Hash containing the arguments to pass to the Ansible module."

    def change_to_s(current, desire)
      @output
    end

    def should_to_s(value)
      @output
    end

    def is_to_s(value)
      "n/a"
    end

    def retrieve
      @changed, @output, @status = provider.run()
          
      fail("Execution of Ansible module #{resource[:module]} failed: " + @output) if @status != 0

      if @changed
        return nil
      else
        return should
      end
    end

    def sync
      # Nothing to do here, changes were already applied in retrieve.
      # Needs to be overwritten to prevent execution of default implementation.
    end
  end
end
