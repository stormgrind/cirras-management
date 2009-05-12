require 'rubygems'
require 'sinatra'
require 'base64'

require 'jboss-cloud-management/model/node'
require 'jboss-cloud-management/handler/back-end-appliance-handler'
require 'jboss-cloud-management/handler/management-appliance-handler'

module JBossCloudManagement
  class URIs
    def initialize( config )
      @config = config

      set_sinatra_parameters

      case @config.appliance_name
        when APPLIANCE_TYPE[:backend]
          @handler = BackEndApplianceHandler.new
        when APPLIANCE_TYPE[:management]
          @handler = ManagementApplianceHandler.new
      end

      @handler.handle unless @handler.nil?

      handle_default
    end

    def set_sinatra_parameters
      enable  :raise_errors
      disable :logging
    end

    def handle_default
      get '/info' do
        node = Node.new( Manager.config.appliance_name )
        Base64.encode64( node.to_yaml )
      end

      get '/*' do
        "OK"
      end
    end
  end
end


