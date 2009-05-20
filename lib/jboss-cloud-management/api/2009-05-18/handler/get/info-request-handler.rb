require 'jboss-cloud-management/model/node'
require 'jboss-cloud-management/event/event-manager'
require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'

module JBossCloudManagement
  class InfoRequestHandler < BaseRequestHandler
    def initialize( prefix, config )
      super( prefix, config )
    end

    def info_request
    end

    def define_handle
      get @prefix do
        EventManager.instance.notify( :info_request )

        Manager.config.node.to_yaml
      end
    end
  end
end