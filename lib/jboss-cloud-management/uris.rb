require 'rubygems'
require 'sinatra'
require 'base64'

require 'jboss-cloud-management/model/node'

module JBossCloudManagement
  class URIs
    def initialize( config )
      @config = config

      set_sinatra_parameters

      if @config.is_management_appliance?
        handle_management
      end

      handle_get
    end

    def set_sinatra_parameters
      enable  :raise_errors
      disable :logging
    end

    def handle_management

    end

    def handle_get
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


