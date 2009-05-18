require 'rubygems'
require 'fastthread'
require 'yaml'

require 'jboss-cloud-management/api/request-handler'
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
        if @config.running_on_ec2
          @node_manager = AWSNodeManager.new( @config )
        else
          @node_manager = DefaultNodeManager.new( @config )
        end

        create_client
      end

      for api in APIS
        RequestHandler.new( @config, api )
      end

      # bind latest api to "latest" prefix
      RequestHandler.new( @config, @config.api, "latest" )

      wait_for_web_server
    end

    def wait_for_web_server
      t = Thread.new do
        while true do
          @log.info "Waiting for web server..."
          break if IPHelper.new.is_port_open?( "localhost", @config.port )
          sleep 1
        end
        @log.info "Web server is running and ready for requests!"
        update_node_list_periodically
      end
    end

    def create_client
      puts @node_manager.get_nodes_by_type( APPLIANCE_TYPE[:management] )
    end

    def nodes
      @node_manager.nodes
    end

    def self.config
      @@config
    end

    def update_node_list_periodically
      t = Thread.new do
        while true do
          @node_manager.register_nodes
          sleep @config.sleep # check after 30 sec if there are changes in nodes (new added, removed, etc)
        end
      end
    end
  end
end
