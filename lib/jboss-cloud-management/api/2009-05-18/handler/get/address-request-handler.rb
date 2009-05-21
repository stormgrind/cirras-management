require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'

module JBossCloudManagement
  class AddressRequestHandler < BaseRequestHandler
    def initialize( path, config, prefix, api_version )
      super( path, config, prefix, api_version  )
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
        addresses.to_yaml
      end
    end
  end
end
