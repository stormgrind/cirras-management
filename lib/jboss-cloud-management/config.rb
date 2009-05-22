require 'jboss-cloud-management/helper/config-helper'
require 'jboss-cloud-management/model/node'

module JBossCloudManagement

  class Config

    def initialize( log )
      @log = log

      config = YAML.load_file( "/etc/jboss-cloud" )
      raise "Invalid config file!" unless config

      @observers        = []

      @port             = 4545          # port used to listen on
      @timeout          = 2             # time to wait for response from other node (in seconds)
      @sleep            = 30            # time to wait before next node querying

      @appliance_name   = config['appliance_name']
      @node             = Node.new( @appliance_name )
      @config_helper    = ConfigHelper.new( @log )
      @running_on_ec2   = @config_helper.is_ec2?

      @rack_config      = YAML.load_file( "config/config.yaml" )
      @leases_file      = "/var/lib/dhcpd/dhcpd.leases"

      configure :test, :development do
        @leases_file    = "test/leases"
      end

    end

    attr_reader :rack_config
    attr_reader :running_on_ec2
    attr_reader :port
    attr_reader :timeout
    attr_reader :sleep
    attr_reader :leases_file
    attr_reader :node

    attr_accessor :appliance_name

    def is_management_appliance?
      @appliance_name.eql?(APPLIANCE_TYPE[:management])
    end

  end
end