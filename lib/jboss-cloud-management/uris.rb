require 'rubygems'
require 'sinatra'
require 'base64'

require 'response'


module JBossCloudManagement
  class URIs
    def initialize
      handle_get
    end

    def handle_get
      get '/*' do
        

        #i request.ip
        Base64.b64encode(Response.new( Config.instance.appliance_names ).to_yaml)
      end
    end
  end
end


