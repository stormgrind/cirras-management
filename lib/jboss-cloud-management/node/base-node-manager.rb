require 'rubygems'
require 'restclient'
require 'timeout'
require 'yaml'
require 'base64'
require 'resolv'
require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/model/node'

module JBossCloudManagement
  class BaseNodeManager
    def initialize( config )
      @log        = LogHelper.instance.log
      @nodes      = {}
      @addresses  = []
      @config     = config

      @ip_helper  = IPHelper.new
    end

    attr_reader :nodes

    def node_addresses
      # only a stub, should be implemented in other class
      raise "NotImplemented!"
    end

    def ping_test( addresses )
      valid_addresses = []

      for ip in addresses
        @log.info "IP: #{ip}, checking if host is alive..."
        if Ping.pingecho( ip, 2 )
          @log.info " \\__ ALIVE: Host #{ip} is alive, good"
          valid_addresses.push( ip )
        else
          @log.info " \\__ DEAD: Host #{ip} hadn't responded in #{2} seconds, not so good, suspecting as dead, removing from cache"
        end
      end

      log_discovery_summary( valid_addresses )

      valid_addresses
    end

    def log_discovery_summary( addresses )
      if addresses.size > 0
        @log.info "Found #{addresses.size} valid address#{addresses.size > 1 ? "es" : ""}: #{addresses.join(", ")}."
      else
        @log.info "No valid addresses found."
      end
    end

    def register_nodes
      @log.info "Updating node list..."

      @addresses = ping_test( node_addresses )

      @log.info "Getting information from nodes..."

      node_list = []

      for address in @addresses
        info = get_info_from_node( address )

        # if we got no response from node go to next node
        next if info.nil?

        node = YAML.load( Base64.decode64( info ) )

        unless node == false or node.class.eql?(Node)
          @log.info "Not a valid response from node #{address}, ignoring."
          next
        end

        node.address  = address

        @log.info "Found a #{node.name} on #{node.address}"

        node_list.push( node )
      end

      added = updated = removed = 0
      nodes = {}

      for node in node_list
        node.address = convert_to_ipv4( node.address )

        nodes[node.address] = node

        # if we have already a node with that IP and node name is the same
        next if @nodes.has_key?( node.address ) and @nodes[node.address].name.eql?( node.name )

        if @nodes.has_key?( node.address )
          updated += 1
        else
          added += 1
        end
      end

      deleted = nodes.size > @nodes.size ? 0 : @nodes.size - nodes.size

      @nodes = nodes

      @log.info "Node list updated (added: #{added}, updated: #{updated}, deleted: #{deleted}), found #{@nodes.size} node#{@nodes.size > 1 ? "s" : ""}."
    end

    def get_info_from_node( address )
      @log.info "Getting info from node #{address}..."

      resource = "http://#{address}:#{@config.port}"

      if @ip_helper.is_port_open?( address, @config.port )
        return get( "#{resource}/info", address )
      else
        @log.warn "Port #{@config.port} is closed on node #{address}, ignoring."
      end
      nil
    end

    def get( url, address )
      begin
        Timeout::timeout(@config.timeout) do
          return RestClient.get( url )
        end
      rescue Timeout::Error
        @log.warn "Node #{address} hasn't replied in #{@config.timeout} seconds for GET request on #{address}."
      end
      nil
    end

    def convert_to_ipv4( address )
      return address if address.match(/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/)
      return Resolv.getaddress( address )
    end

    def get_node_by_address( address )
      @nodes[address]
    end

    def get_nodes_by_type( type )
      nodes = []
      @nodes.each_value {| node | nodes.push( node ) if node.name.eql?( type ) }
      nodes
    end

  end
end
