require 'rubygems'
require 'fastthread'
require 'sinatra'
require 'yaml'

require 'jboss-cloud-management/config'
require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/helper/log-helper'
require 'jboss-cloud-management/node/aws-node-manager'
require 'jboss-cloud-management/node/default-node-manager'

module JBossCloudManagement

  APPLIANCE_TYPE = {
          :httpd          => "httpd-appliance",
          :jbossas5       => "jboss-as5-appliance",
          :backend        => "back-end-appliance",
          :frontend       => "front-end-appliance",
          :jbossjgroups   => "jboss-jgroups-appliance",
          :management     => "management-appliance",
          :meta           => "meta-appliance",
          :postgis        => "postgis-appliance"
  }

  APIS = [ "2009-05-18" ]

  class Manager
    def initialize
      @config           = Config.new
      @@config          = @config

      @log = LogHelper.instance.log

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

      wait_for_web_server
    end

    def bind_handler( api_version, prefix = nil )
      prefix = api_version if prefix.nil?

      Dir["lib/jboss-cloud-management/api/#{api_version}/handler/*/*"].each {|file| require file if File.exists?( file ) }

      if @config.is_management_appliance?
        handler = ManagementApplianceRequestHandlerHelper.new( api_version, prefix )
      else
        handler = DefaultRequestHandlerHelper.new( api_version, prefix )
      end

      #DefaultRequestHandlerHelper.new( @api_version, @prefix ).define_handlers

      handler.define_handlers
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
