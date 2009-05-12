require 'rubygems'
require 'fastthread'
require 'yaml'

require 'jboss-cloud-management/uris'
require 'jboss-cloud-management/config'
require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/helper/log-helper'
require 'jboss-cloud-management/node/aws-node-manager'
require 'jboss-cloud-management/node/default-node-manager'

module JBossCloudManagement
  class Manager
    def initialize
      @config           = Config.new
      @@config          = @config

      @log = LogHelper.instance.log

      if @config.running_on_ec2
        @node_manager = AWSNodeManager.new( @config )
      else
        @node_manager = DefaultNodeManager.new( @config )
      end

      URIs.new( @config )

      @config.is_management_appliance?

      wait_for_web_server
    end

    def wait_for_web_server
      t = Thread.new do
        while true do
          @log.info "Waiting for web server..."
          break if IPHelper.new.is_port_open?( "localhost", @config.port )
          sleep 1
        end
        update_node_list_periodically
      end
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
