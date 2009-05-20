require 'jboss-cloud-management/api/2009-05-18/handler/get/info-request-handler'

module JBossCloudManagement
  class BaseRequestHandlerHelper
    def initialize( api_version, prefix, config )
      @api_version  = api_version
      @prefix       = prefix
      @config       = config
      @handlers     = {}
      @log          = LogHelper.instance.log

      register_handler( InfoRequestHandler.new( "/#{@prefix}/info", @config ) )
    end

    attr_reader :handlers

    def register_handler( handler )
      @log.debug "Registering handler #{handler.class} for prefix '#{handler.prefix}'..."

      @handlers[handler.prefix] = handler
    end
  end
end
