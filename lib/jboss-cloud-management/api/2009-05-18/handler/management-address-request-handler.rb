require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'
require 'jboss-cloud-management/helper/log-helper'

module JBossCloudManagement
  class ManagementAddressRequestHandler < BaseRequestHandler
    def initialize( prefix )
      super( prefix )
    end

    def define_handle
      put @prefix do
        return if params[:address].nil?

        address = params[:address].strip

        LogHelper.instance.log.info "Got new management-appliance address: #{address}"

        Manager.config.management_appliance_address = address
      end
    end
  end
end
