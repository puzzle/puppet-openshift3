module Puppet::Parser::Functions
  newfunction(:hiera_groups_to_inventory, :type => :rvalue) do |args|
    result = ""        
    args[0].each do |group, value|
      result += "[#{group}]\n"
      result += function_hiera_to_inventory([value])      
    end

    return result
  end
end
