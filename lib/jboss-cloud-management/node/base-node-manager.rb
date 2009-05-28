# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'rubygems'
require 'restclient'
require 'timeout'
require 'yaml'
require 'base64'
require 'resolv'
require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/helper/client-helper'
require 'jboss-cloud-management/model/node'

module JBossCloudManagement
  class BaseNodeManager
    def initialize( config )
      @log        = LogHelper.instance.log
      @nodes      = {}
      @addresses  = []
      @config     = config

      @ip_helper      = IPHelper.new
      @client_helper  = ClientHelper.new( @config, @log )
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
          @log.info " \\__ DEAD: Host #{ip} hadn't responded in #{2} seconds, not so good, suspecting as dead"
        end
      end

      log_discovery_summary( valid_addresses )

      valid_addresses
    end

    def log_discovery_summary( addresses )
      if addresses.size > 0
        @log.info "Found #{addresses.size} address#{addresses.size > 1 ? "es" : ""}: #{addresses.join(", ")}."
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
        node = get_info_from_node( address )

        if node.nil? or !node.class.eql?(Node)
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
        return @client_helper.get( "#{resource}/latest/info" )
      else
        @log.warn "Port #{@config.port} is closed on node #{address}, ignoring."
      end
      nil
    end

    def push_management_address
      management_appliances = nodes_by_type( APPLIANCE_TYPE[:management] )

      return if management_appliances.size  == 0

      address   = management_appliances.first.address
      nodes     = {}
      count     = 0

      @nodes.each { |ip, node| nodes[ip] = node unless node.name.eql?( APPLIANCE_TYPE[:management] ) }

      if nodes.size == 0
        @log.info "No nodes found to push #{APPLIANCE_TYPE[:management]} address"
        return
      end

      @log.debug "Pushing management node address (#{address}) to #{nodes.size} nodes..."

      nodes.each do |ip, node|
        @log.debug "Pushing management node address #{address} to #{node.name} on #{ip}..."
        @client_helper.put( "http://#{ip}:#{@config.port}/latest/address/#{APPLIANCE_TYPE[:management]}", :address => address )
        @log.debug "Done"
        count += 1
      end

      @log.debug "Management node address pushed to #{count} nodes"
    end

    def convert_to_ipv4( address )
      return address if address.match(/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/)
      return Resolv.getaddress( address )
    end

    def node_by_address( address )
      @nodes[address]
    end

    def nodes_by_type( type )
      nodes = []
      @nodes.each_value {| node | nodes.push( node ) if node.name.eql?( type ) }
      nodes
    end
  end
end
