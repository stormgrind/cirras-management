require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'
require 'jboss-cloud-management/helper/log-helper'
require 'jboss-cloud-management/helper/client-helper'

module JBossCloudManagement
  class ManagementAddressRequestHandler < BaseRequestHandler
    def initialize( prefix, config )
      super( prefix, config )

      @client_helper = ClientHelper.new( @config )
    end

    def management_address_request( address )
      @log.info "Got new management-appliance address: #{address}"

      case @config.appliance_name
        when APPLIANCE_TYPE[:backend]
          # if we're a back-end appliance, ask for front-end appliance address to inject it to /etc/jboss-as5.conf

          Thread.new do
            while true do
              @log.debug "Asking for front-end appliance address..."

              front_end_address = client_helper.get( "http://#{address}:#{config.port}/latest/address/#{APPLIANCE_TYPE[:frontend]}", address )

              puts front_end_address

              @log.debug "Waiting #{@config.sleep} seconds before next node discovery..."
              sleep @config.sleep # check after 30 sec if there are changes in nodes (new added, removed, etc)
            end
          end

        else
      end

    end

    def define_handle
      put @prefix do
        pass if params[:address].nil?

        EventManager.instance.notify( :management_address_request, params[:address].strip )
      end
    end
  end
end
