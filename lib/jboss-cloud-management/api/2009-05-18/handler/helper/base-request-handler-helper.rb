require 'jboss-cloud-management/api/2009-05-18/handler/get/info-request-handler'

module JBossCloudManagement
  class BaseRequestHandlerHelper
    def initialize( to )
      @to           = to
      @api_version  = to.api_version
      @prefix       = to.prefix
      @config       = to.config
      @log          = to.log
      @handlers     = {}

      register_handler( :info_request, InfoRequestHandler.new( "/#{@prefix}/info", @to ) )
    end

    attr_reader :handlers

    def register_handler( event, handler )
      @handlers[event] = [] if @handlers[event].nil?
      @handlers[event].push handler
    end
  end
end
