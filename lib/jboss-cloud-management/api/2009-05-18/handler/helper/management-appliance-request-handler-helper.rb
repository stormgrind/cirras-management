require 'jboss-cloud-management/api/2009-05-18/handler/helper/base-request-handler-helper'
require 'jboss-cloud-management/api/2009-05-18/handler/get/address-request-handler'

module JBossCloudManagement
  class ManagementApplianceRequestHandlerHelper < BaseRequestHandlerHelper
    def initialize( api_version, prefix, config )
      super( api_version, prefix, config )

      register_handler( :address_request, AddressRequestHandler.new( "/#{@prefix}/address/:appliance", @config, @prefix, @api_version ) )
    end
  end
end
