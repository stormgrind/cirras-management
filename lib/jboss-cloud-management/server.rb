libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'fastthread'
require 'yaml'
require 'logger'
require 'singleton'

require 'uris'
require 'client'
require 'manage'
require 'helper/config-helper'

module JBossCloudManagement
  class Config
    include Singleton

    def initialize
      @nodes = []

      @port     = 4545
      @timeout  = 2

      helper   = ConfigHelper.new
      @appliance_names =  helper.appliance_names
    end

    attr_accessor :nodes
    attr_accessor :port
    attr_accessor :timeout
    attr_accessor :appliance_names
  end

  class Server
    def initialize
      @manager  = Manager.new
      @config   = Config.instance
      @log      = Logger.new(STDOUT)

      prepare_uris
      update_node_list_periodically
    end

    def prepare_uris
      URIs.new
    end

    def update_node_list
      @log.info "Updating node list..."
      Config.instance.nodes = @manager.valid_nodes
      @log.info "Node list updated, found #{Config.instance.nodes.size} nodes."
    end

    def get_info_from_nodes
      @log.info "Getting information from nodes..."
      for node in Config.instance.nodes
        client = Client.new( node, @config )
        client.get_info
      end
    end

    def update_node_list_periodically
      t = Thread.new do
        while true do
          update_node_list
          get_info_from_nodes
          sleep 30 # check after 30 sec if there are changes in nodes (new added, removed, etc)
        end
      end
    end
  end
end
