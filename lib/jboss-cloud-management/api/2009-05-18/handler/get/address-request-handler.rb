require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'

module JBossCloudManagement
  class AddressRequestHandler < BaseRequestHandler
    def initialize( prefix, config )
      super( prefix, config )
    end

    def define_handle     
      get @prefix do
        EventManager.instance.notify( :address_request )

        addresses = []
        Manager.node_manager.nodes_by_type( params[:appliance] ).each do |node|
          addresses.push( node.address )
        end
        addresses.to_yaml
      end
    end
  end
end
