require 'base64'
require 'jboss-cloud-management/model/node'

module JBossCloudManagement
  class RequestHelper
    def self.encode_and_send( msg )
      Base64.encode64( node.to_yaml )
    end
  end

  class BaseRequestHandler
    def initialize

    end

    def handle
      get '/info' do
        node = Node.new( Manager.config.appliance_name )
        node.to_yaml
      end
    end
  end
end
