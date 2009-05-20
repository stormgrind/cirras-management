require 'jboss-cloud-management/api/2009-05-18/handler/get/info-request-handler'

module JBossCloudManagement
  class BaseRequestHandlerHelper
    def initialize( api_version, prefix, config )
      @api_version  = api_version
      @prefix       = prefix
      @config       = config
      @handlers     = {}
      @log          = LogHelper.instance.log

      register_handler( InfoRequestHandler.new( "/#{@prefix}/info", @config, @prefix, @api_version ), :info_request )
    end

    attr_reader :handlers

    def register_handler( handler, event )
      @handlers[event] = [] if @handlers[event].nil?
      @handlers[event].push handler
    end
  end
end
