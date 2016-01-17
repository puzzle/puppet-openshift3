module Puppet::Parser::Functions
  newfunction(:hiera_to_inventory, :type => :rvalue) do |args|
    result = ""
    args[0].each do |config|
      result += config['name']
      config.each do |key, value|
        next if key == 'name'
#        if value =~ /^(y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$/
#          result += " openshift_#{key}=#{value}"
        if value.is_a?(TrueClass) || value.is_a?(FalseClass)
          result += " openshift_#{key}=#{value}"
        elsif value.is_a?(String)
          result += " openshift_#{key}='#{value}'"
        else
          result += " openshift_#{key}='#{value.to_json}'"
        end
      end
    end
    
    return result + "\n"
  end
end
