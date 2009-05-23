require 'jboss-cloud-management/model/node'
require 'jboss-cloud-management/event/event-manager'
require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'

module JBossCloudManagement
  class InfoRequestHandler < BaseRequestHandler
    def initialize( path, to )
      super( path, to )
    end

    def info_request
    end

    def define_handle
      get @path do
        notify( :info_request )

        Base64.b64encode( Manager.config.node.to_yaml )
      end
    end
  end
end
