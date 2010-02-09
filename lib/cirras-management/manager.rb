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

require 'yaml'

require 'cirras-management/model/config'
require 'cirras-management/helper/ip-helper'
require 'cirras-management/helper/log-helper'
require 'cirras-management/node/aws-node-manager'
require 'cirras-management/node/default-node-manager'
require 'cirras-management/event/event-manager'
require 'cirras-management/model/handler-to'
require 'cirras-management/defaults'

require 'sinatra'

module CirrASManagement
  class Manager
    def initialize

      @log = LogHelper.instance.log

      @config           = ConfigHelper.new( :log => @log ).config
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
      disable :lock

      helpers do
        def prefix
          request.path_info.match( /^\/([\w\-]+)\// )[1]
        end

        def notify( event, *args )
          EventManager.instance.notify( false, prefix, event, *args )
        end

        def notify_threaded( event, *args )
          EventManager.instance.notify( true, prefix, event, *args )
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

      Dir["lib/cirras-management/api/#{api_version}/handler/*/*"].each {|file| require file if File.exists?( file ) }

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
