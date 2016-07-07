module Puppet::Parser::Functions
  newfunction(:hiera_vars_to_inventory, :type => :rvalue) do |args|
    result = ""
    args[0].each do |key, value|
      if value.is_a?(TrueClass)
        result += "#{key}=True\n"
      elsif value.is_a?(FalseClass)
        result += "#{key}=False\n"
      elsif value.is_a?(String)
       result += "#{key}='#{value.gsub(/\n/, %q{\\n})}'\n"
      else
        result += "#{key}=#{value.to_json}\n"
      end
    end

    return result
  end
end
