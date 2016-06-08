Puppet::Type.type(:rhsm_repo).provide(:subscription_manager) do
  @doc = <<-EOS
    This provider registers a software repository via RedHat subscription manager.
  EOS

  confine :osfamily => :redhat
  confine :feature => :json

  commands :subscription_manager => "subscription-manager"

  def create
    subscription_manager('repos','--enable',@resource[:name])
  end

  def destroy
    subscription_manager('repos','--disable',@resource[:name])
  end

  def self.instances
    repo_file = '/var/lib/rhsm/cache/content_overrides.json'
    repo_instances = Array.new
    if File.exists?(repo_file)
      repos = JSON.parse(File.open(repo_file).read)
      repos.each do |repo|
        if repo.has_key?('value') && repo['value'] == '1'
          n = repo['contentLabel']
          repo_instances.push( new( :name => n, :ensure => :present ))
        end
      end
    end
    return repo_instances  
  end

  def self.prefetch(resources)
    repos = instances
    resources.keys.each do |name|
      if provider = repos.find{ |repo| repo.name == name }
        resources[name].provider = provider 
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

end
