module Puppet::Parser::Functions
  newfunction(:hiera_group_vars_to_inventory, :type => :rvalue) do |args|
    result = ""        
    args[0].each do |group, value|
      result += "[#{group}:vars]\n"
      result += function_hiera_vars_to_inventory([value])      
    end

    return result
  end
end
