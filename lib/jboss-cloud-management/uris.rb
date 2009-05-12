require 'rubygems'
require 'sinatra'
require 'base64'

require 'jboss-cloud-management/response'

module JBossCloudManagement
  class URIs
    def initialize( config )
      @config = config

      set_sinatra_parameters
      handle_get
    end

    def set_sinatra_parameters
      enable  :raise_errors
      disable :logging
    end

    def handle_get
      get '/*' do
        cloud_response = Response.new

        cloud_response.appliance_name = Manager.config.appliance_name

        Base64.encode64( cloud_response.to_yaml )
      end
    end
  end
end


