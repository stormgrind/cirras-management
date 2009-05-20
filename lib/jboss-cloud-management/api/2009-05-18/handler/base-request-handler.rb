require 'jboss-cloud-management/event/event-manager'

module JBossCloudManagement
  class BaseRequestHandler
    def initialize( path, config, prefix, api_version )
      @path         = path
      @prefix       = prefix
      @config       = config
      @api_version  = api_version
      @log          = LogHelper.instance.log

      define_handle
    end

    attr_reader :prefix

    def define_handle
      raise "NotImplemented"
    end
  end
end
