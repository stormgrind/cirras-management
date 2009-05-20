require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'
require 'jboss-cloud-management/helper/log-helper'
require 'jboss-cloud-management/helper/client-helper'

module JBossCloudManagement
  class ManagementAddressRequestHandler < BaseRequestHandler
    def initialize( path, config, prefix, api_version )
      super( path, config, prefix, api_version  )

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

              front_end_address = @client_helper.get( "http://#{address}:#{config.port}/latest/address/#{APPLIANCE_TYPE[:frontend]}", address )

              puts front_end_address

              # inject front-end appliance address to /etc/jboss-as5.conf

              break unless front_end_address.nil?
              sleep 10
            end
          end

        else
      end

    end

    def define_handle
      put @path do
        pass if params[:address].nil?

        notify( :management_address_request, params[:address].strip )
      end
    end
  end
end
