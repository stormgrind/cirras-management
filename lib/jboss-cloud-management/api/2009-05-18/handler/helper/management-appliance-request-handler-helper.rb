require 'jboss-cloud-management/api/2009-05-18/handler/helper/base-request-handler-helper'
require 'jboss-cloud-management/api/2009-05-18/handler/address-request-handler'

module JBossCloudManagement
  class ManagementApplianceRequestHandlerHelper < BaseRequestHandlerHelper
    def initialize( api_version, prefix )
      super( api_version, prefix )
    end

    def define_handlers
      @handlers["/#{@prefix}/address/:appliance"] = AddressRequestHandler.new( "/#{@prefix}/address/:appliance" )
    end
  end
end
