require 'rubygems'
require 'fastthread'
require 'yaml'
require 'logger'
require 'singleton'
require 'base64'
require 'resolv'

require 'jboss-cloud-management/uris'
require 'jboss-cloud-management/config'
require 'jboss-cloud-management/node'
require 'jboss-cloud-management/client'
require 'jboss-cloud-management/helper/config-helper'
require 'jboss-cloud-management/helper/ip-helper'

module JBossCloudManagement
  class Manager
    def initialize
      @config     = Config.new
      @log        = Logger.new(STDOUT)
      @ip_helper  = IPHelper.new

      @nodes      = {}

      Manager.config = @config

      URIs.new( @config )
      update_node_list_periodically
    end

    def self.config
      @@config
    end

    def self.config=( config )
      @@config = config
    end

    def update_node_list
      @log.info "Updating node list..."
      @config.nodes = @ip_helper.node_ips
      @log.info "Node list updated, found #{@config.nodes.size} nodes."
    end

    def get_info_from_nodes
      @log.info "Getting information from nodes..."
      for address in @config.nodes
        client  = Client.new( address, @config )
        info    = client.get_info

        # if we got no response from node go to next node
        next if info.nil?

        response  = YAML.load( Base64.decode64( info ) )
        node      = Node.new( response.appliance_name, address )

        register_node( node )
      end
    end

    def register_node( node )
      node.address = convert_to_ipv4( node.address )

      if @nodes.has_key?( node.address )
        @nodes[node.address] = node unless @nodes[node.address].name.eql?( node.name )
      else
        @nodes[node.address] = node
      end
    end

    def convert_to_ipv4( address )
      return address if address.match(/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/)
      return Resolv.getaddress( address )
    end

    def update_node_list_periodically
      t = Thread.new do
        while true do
          update_node_list
          get_info_from_nodes
          sleep @config.sleep # check after 30 sec if there are changes in nodes (new added, removed, etc)
        end
      end
    end
  end
end
