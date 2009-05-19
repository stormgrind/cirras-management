require 'jboss-cloud-management/model/node'
require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'

module JBossCloudManagement
  class InfoRequestHandler < BaseRequestHandler
    def initialize( prefix )
      super( prefix )
    end

    def define_handle
      get @prefix do
        node = Node.new( Manager.config.appliance_name )
        node.to_yaml
      end
    end
  end
end
