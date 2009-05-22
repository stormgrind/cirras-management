require 'yaml'

require 'jboss-cloud-management/config'
require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/helper/log-helper'
require 'jboss-cloud-management/node/aws-node-manager'
require 'jboss-cloud-management/node/default-node-manager'
require 'jboss-cloud-management/event/event-manager'
require 'jboss-cloud-management/api/2009-05-18/handler/handler-to'

require 'sinatra'

module JBossCloudManagement

  APPLIANCE_TYPE = {
          :backend        => "back-end-appliance",
          :frontend       => "front-end-appliance",
          :management     => "management-appliance",
          :postgis        => "postgis-appliance"
  }

  APIS = [ "2009-05-18" ]

  class Manager
    def initialize

      @log = LogHelper.instance.log

      @config           = Config.new( @log )
      @@config          = @config

      @log.info "Setting up management environment for #{@config.appliance_name}"

      if @config.is_management_appliance?
        @log.info "Setting up node managers..."

        if @config.running_on_ec2
          @node_manager = AWSNodeManager.new( @config )
        else
          @node_manager = DefaultNodeManager.new( @config )
        end

        @@node_manager = @node_manager
      else
        create_client
      end

      # sinatra parameters
      enable  :raise_errors
      disable :logging

      helpers do
        def prefix
          request.path_info.match( /^\/([\w\-]+)\// )[1]
        end

        def notify( event, *args )
          EventManager.instance.notify( prefix, event, *args )
        end

      end

      for api in APIS
        bind_handler( api )
      end

      bind_handler( APIS.first, "latest" )

      get '/' do
        apis = "latest\n"
        for api in APIS
          apis += api + "\n"
        end

        apis
      end

      get '/*' do
        status 404
        "Not found"
      end

      wait_for_web_server
    end

    def bind_handler( api_version, prefix = nil )
      prefix = api_version if prefix.nil?

      @log.debug "Binding new request handler helper for API version '#{api_version}' and prefix '#{prefix}'..."

      Dir["lib/jboss-cloud-management/api/#{api_version}/handler/*/*"].each {|file| require file if File.exists?( file ) }

      to = HandlerTO.new( prefix, api_version, @config, @log )

      if @config.is_management_appliance?
        handler_helper = ManagementApplianceRequestHandlerHelper.new( to )
      else
        handler_helper = DefaultRequestHandlerHelper.new( to )
      end

      EventManager.instance.register( api_version, prefix, handler_helper.handlers )
    end

    def wait_for_web_server
      t = Thread.new do
        while true do
          @log.info "Waiting for web server..."
          break if IPHelper.new.is_port_open?( "localhost", @config.port )
          sleep 1
        end
        @log.info "Web server is running and ready for requests!"
        discover_nodes if @config.is_management_appliance?
      end
    end

    # this is a client

    def create_client
    end

    def nodes
      @node_manager.nodes
    end

    def self.config
      @@config
    end

    def self.node_manager
      @@node_manager
    end

    def discover_nodes
      t = Thread.new do
        while true do
          @log.debug "Begining node discovery..."
          @node_manager.register_nodes
          @node_manager.push_management_address
          @log.debug "Waiting #{@config.sleep} seconds before next node discovery..."
          sleep @config.sleep # check after 30 sec if there are changes in nodes (new added, removed, etc)
        end
      end
    end
  end
end
