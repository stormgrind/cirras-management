require 'jboss-cloud-management/api/2009-05-18/handler/helper/base-request-handler-helper'
require 'jboss-cloud-management/api/2009-05-18/handler/put/management-address-request-handler'

module JBossCloudManagement
  class DefaultRequestHandlerHelper < BaseRequestHandlerHelper
    def initialize( to )
      super( to )

      register_handler( :management_address_request, ManagementAddressRequestHandler.new( "/#{@prefix}/address/#{APPLIANCE_TYPE[:management]}", @to ) )
    end
  end
end
