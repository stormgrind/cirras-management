require 'jboss-cloud-management/api/2009-05-18/handler/helper/base-request-handler-helper'
require 'jboss-cloud-management/api/2009-05-18/handler/put/management-address-request-handler'

module JBossCloudManagement
  class DefaultRequestHandlerHelper < BaseRequestHandlerHelper
    def initialize( api_version, prefix, config )
      super( api_version, prefix, config )

      register_handler( ManagementAddressRequestHandler.new( "/#{@prefix}/address/#{APPLIANCE_TYPE[:management]}", @config ) )
    end
  end
end
