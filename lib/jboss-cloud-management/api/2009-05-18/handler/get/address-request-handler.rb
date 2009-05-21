require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'

module JBossCloudManagement
  class AddressRequestHandler < BaseRequestHandler
    def initialize( path, to )
      super( path, to )
    end

    def address_request
    end

    def define_handle
      get @path do
        notify( :address_request )

        addresses = []
        Manager.node_manager.nodes_by_type( params[:appliance] ).each do |node|
          addresses.push( node.address )
        end

        # just for testing:
        addresses.push "127.0.0.1"

        addresses.to_yaml
      end
    end
  end
end
