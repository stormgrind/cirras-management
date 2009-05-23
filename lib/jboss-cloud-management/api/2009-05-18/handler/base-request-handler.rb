require 'base64'
require 'jboss-cloud-management/event/event-manager'

module JBossCloudManagement
  class BaseRequestHandler
    def initialize( path, to )
      @path         = path
      @prefix       = to.prefix
      @config       = to.config
      @api_version  = to.api_version
      @log          = to.log

      define_handle
    end

    def define_handle
      raise "NotImplemented"
    end
  end
end
