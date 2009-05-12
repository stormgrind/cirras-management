require 'jboss-cloud-management/helper/config-helper'

module JBossCloudManagement
  class Config
    def initialize
      config = YAML.load_file( "/etc/jboss-cloud" )
      raise "Invalid config file!" unless config

      @port             = 4545  # port used to listen on
      @timeout          = 2     # time to wait for response from other node (in seconds)
      @sleep            = 30    # time to wait before next node querying

      @appliance_name   = config['appliance_name']

      @config_helper    = ConfigHelper.new

      @running_on_ec2   = @config_helper.is_ec2?

    end

    attr_accessor :port
    attr_accessor :timeout
    attr_accessor :appliance_name
    attr_accessor :sleep
    attr_accessor :running_on_ec2
  end
end