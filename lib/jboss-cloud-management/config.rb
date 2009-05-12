module JBossCloudManagement
  class Config
    def initialize
      config = YAML.load_file( "/etc/jboss-cloud" )
      raise "Invalid config file!" unless config

      @nodes            = []
      @port             = 4545  # port used to listen on
      @timeout          = 2     # time to wait for response from other node (in seconds)
      @sleep            = 30    # time to wait before next node querying

      @appliance_name   = config['appliance_name']

      @web_log_file     = "/var/log/messages/jboss-cloud-management-web.log"

    end

    attr_accessor :nodes
    attr_accessor :port
    attr_accessor :timeout
    attr_accessor :appliance_name
    attr_accessor :sleep
    attr_accessor :web_log_file
  end
end