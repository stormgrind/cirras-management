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

require 'cirras-management/helper/string-helper'
require 'cirras-management/helper/client-helper'

module CirrASManagement
  class UpdateGossipHostAddressCommand

    JBOSS_GOSSIP_HOST = 'JBOSS_GOSSIP_HOST'

    def initialize( options = {} )
      @log              = options[:log]             || Logger.new(STDOUT)
      @string_helper    = options[:string_helper]   || StringHelper.new( { :log => @log } )
      @client_helper    = options[:client_helper]   || ClientHelper.new( { :log => @log } )
      @mgmt_address     = options[:mgmt_address]
    end

    def execute
      unless load_gossip_host
        @log.error "Couldn't load Gossip host, check logs for errors."
        return
      end

      @jboss_config = File.read(JBOSS_SYSCONFIG_FILE)
      @current_gossip_host = @string_helper.prop_value( @jboss_config, JBOSS_GOSSIP_HOST )

      @log.info "Current Gossip host value is '#{@current_gossip_host}'" if @current_gossip_host.length > 0

      unless (@current_gossip_host == @gossip_host)
        @log.info "Updating Gossip host to '#{@gossip_host}'..."
        @string_helper.update_config( @jboss_config, JBOSS_GOSSIP_HOST, @gossip_host )
        @log.debug "Gossip host updated."

        return true
      end

      @log.debug "Current and new Gossip host value (#{@gossip_host}) is same, skipping..."

      false
    end

    def load_gossip_host
      if (@mgmt_address.nil?)
        @log.error "No management appliance address specified, cannot get Gossip host address."
        return false
      end

      @log.info "Asking for Gossip host address..."

      response = @client_helper.get( "http://#{@mgmt_address}:#{MANAGEMENT_PORT}/latest/address/#{APPLIANCE_TYPE[:frontend]}" )

      if response.nil? or !response.is_a?(Array)
        @log.error "Got no valid response from management-appliance!"
        return false
      end

      # TODO this should be changed to support multiple Gossip Routers
      @gossip_host = response.first
      
      true
    end
  end
end
