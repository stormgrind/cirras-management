require 'logger'

module JBossCloudManagement
  class LogHelper
    include Singleton

    def initialize
      @log        = Logger.new('/var/log/jboss-cloud-management/default.log')
      @web_log    = Logger.new('/var/log/jboss-cloud-management/web.log')
    end

    attr_reader :log
    attr_reader :web_log

  end
end