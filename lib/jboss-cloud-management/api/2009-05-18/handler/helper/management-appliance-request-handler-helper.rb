require 'jboss-cloud-management/api/2009-05-18/handler/helper/base-request-handler-helper'

module JBossCloudManagement
  class ManagementApplianceRequestHandlerHelper < BaseRequestHandlerHelper
    def initialize( api_version, prefix )
      super( api_version, prefix )
    end

    def define_handlers
      #@handlers["/#{@prefix}/test"] = InfoRequestHandler.new( "/#{@prefix}/test" )
    end
  end
end
