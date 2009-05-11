require 'helper/ip-helper'

module JBossCloudManagement
  class ConfigHelper
    def initialize
      @ace_appliances_location = "/usr"
      #/usr/share/ace/appliances
      @ip_helper = IPHelper.new
    end

    def appliance_names
      names = []

      Dir[ "#{@ace_appliances_location}/*" ].each do |file|
        names.push( File.basename( file ) ) if File.directory?(file)
      end

      names
    end

    def is_ec2?
      @ip_helper.is_port_open?( "169.254.169.254" )
    end

  end
end