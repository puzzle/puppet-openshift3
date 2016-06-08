require 'puppet/property/boolean'
require 'puppet/type'

Puppet::Type.newtype(:rhsm_repo) do
  @doc = ""

  ensurable

  newparam(:name, :namevar => true) do
    desc "The rhsm channel to subscribe to."
  end

end
