require 'logger'
require 'singleton'

module JBossCloudManagement
  class LogHelper
    include Singleton

    def initialize
      @log              = Logger.new('/var/log/jboss-cloud-management/default.log', 10, 1024000)
      @log.level        = Logger::DEBUG      
      @web_log          = Logger.new('/var/log/jboss-cloud-management/web.log', 10, 1024000)
      @client_log_file  = '/var/log/jboss-cloud-management/client.log'
    end

    attr_reader :log
    attr_reader :web_log
    attr_reader :client_log_file

  end
end