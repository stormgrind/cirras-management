require 'rubygems'
require 'fastthread'
require 'yaml'
require 'singleton'

require 'lib/jboss-cloud-management/uris'

$: << 'lib/jboss-cloud-management-support'

require 'lib/jboss-cloud-management/manage'

module JBossCloudManagement
  class Config
    include Singleton

    def initialize
      @nodes = []
    end

    attr_accessor :nodes
  end

  class Server
    def initialize
      @manager  = Manager.new
      @config   = Config.instance

      prepare_uris
      update_nodes_periodically
    end

    attr_reader :nodes

    def prepare_uris
      URIs.new
    end

    def update_nodes
      @config.nodes = @manager.valid_nodes
    end

    def update_nodes_periodically
      t = Thread.new do
        while true do
          update_nodes
          sleep 30 # check after 30 sec if there are changes in nodes (new added, removed, etc)
        end
      end
    end
  end
end

JBossCloudManagement::Server.new
