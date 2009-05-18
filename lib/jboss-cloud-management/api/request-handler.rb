require 'rubygems'
require 'sinatra'

module JBossCloudManagement
  class RequestHandler
    def initialize( config, api )
      @config   = config
      @api      = api

      Dir["lib/jboss-cloud-management/api/#{@api}/handler/*"].each {|file| require file }

      set_sinatra_parameters

      if @config.appliance_name.eql?(APPLIANCE_TYPE[:management])
        @handler = ManagementApplianceRequestHandler.new
      else
        @handler = DefaultRequestHandler.new
      end

      @handler.handle

      handle_default
    end

    def set_sinatra_parameters
      enable  :raise_errors
      disable :logging
    end

    def handle_default
      get '/' do
        apis = "latest\n"
        for api in APIS
          apis += api + "\n"
        end

        apis
      end
    end
  end
end


