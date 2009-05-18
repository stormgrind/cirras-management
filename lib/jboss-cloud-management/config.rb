require 'jboss-cloud-management/helper/config-helper'

module JBossCloudManagement

  class Config
    def initialize
      config = YAML.load_file( "/etc/jboss-cloud" )
      raise "Invalid config file!" unless config

      @port             = 4545          # port used to listen on
      @timeout          = 2             # time to wait for response from other node (in seconds)
      @sleep            = 30            # time to wait before next node querying

      @appliance_name   = config['appliance_name']
      @config_helper    = ConfigHelper.new
      @running_on_ec2   = @config_helper.is_ec2?

      @rack_config      = YAML.load_file( "config/config.ru" )
      @leases_file      = "/var/lib/dhcpd/dhcpd.leases"

      configure :test, :development do
        @leases_file    = "test/leases"
      end

    end

    attr_reader :rack_config
    attr_reader :running_on_ec2
    attr_reader :port
    attr_reader :timeout
    attr_reader :appliance_name
    attr_reader :sleep
    attr_reader :leases_file

    def is_management_appliance?
      @appliance_name.eql?(APPLIANCE_TYPE[:management])
    end

  end
end