module Puppet::Parser::Functions
  newfunction(:hiera_to_inventory, :type => :rvalue) do |args|
    result = ""
    args[0].each do |config|
      result += config['name']
      config.each do |key, value|
        prefix = "openshift_" if not /^(openshift_|osm_|glusterfs_)/ =~ key
        next if key == 'name'
#        if value =~ /^(y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$/
#          result += " openshift_#{key}=#{value}"
        if value.is_a?(TrueClass)
          result += " #{prefix}#{key}=True"
        elsif value.is_a?(FalseClass)
          result += " #{prefix}#{key}=False"
        elsif value.is_a?(String)
          result += " #{prefix}#{key}='#{value}'"
        else
          result += " #{prefix}#{key}='#{value.to_json}'"
        end
      end

      result += "\n"
    end

    return result
  end
end
