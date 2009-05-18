require 'rubygems'
require 'sinatra'

module JBossCloudManagement
  class RequestHandlerHelper
    def initialize( config, api_version, prefix = nil )
      @config         = config
      @api_version    = api_version
      @prefix         = prefix

      @prefix         = @api_version if @prefix.nil?

      Dir["lib/jboss-cloud-management/api/#{@api_version}/handler/*/*"].each {|file| require file if File.exists?( file ) }

      if @config.appliance_name.eql?(APPLIANCE_TYPE[:management])
        @handler = ManagementApplianceRequestHandlerHelper.new( @api_version, @prefix )
      else
        @handler = DefaultRequestHandlerHelper.new( @api_version, @prefix )
      end

      #DefaultRequestHandlerHelper.new( @api_version, @prefix ).define_handlers

      @handler.define_handlers
    end
  end
end


