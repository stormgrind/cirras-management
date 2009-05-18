require 'jboss-cloud-management/api/2009-05-18/handler/info-request-handler'

module JBossCloudManagement
  class BaseRequestHandlerHelper
    def initialize( api_version, prefix )
      @api_version  = api_version
      @prefix       = prefix
      @handlers     = {}

      @handlers["/#{@prefix}/info"] = InfoRequestHandler.new( "/#{@prefix}/info" ) 
    end

    attr_reader :handlers

    def define_handlers
      raise "NotImplemented"
    end
  end
end
