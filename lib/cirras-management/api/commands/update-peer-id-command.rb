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

require 'cirras-management/helper/log-helper'
require 'cirras-management/helper/exec-helper'
require 'cirras-management/api/commands/base-jboss-as-command'

module CirrASManagement
  class UpdatePeerIdCommand < BaseJBossASCommand

    def initialize( options = {} )
      super( { :log => options[:log] } )

      @mgmt_address = options[:mgmt_address]
    end

    def execute
      unless load_peer_id
        @log.error "PeerID wasn't updated, check logs."
        return
      end

      current_value = twiddle_execute( "get jboss.messaging:service=ServerPeer ServerPeerID" ).scan(/^ServerPeerID=(\d+)$/).to_s

      if current_value.nil? or current_value.length == 0
        @log.error "Invalid PeerID value received, will try to override it."
      end

      @log.info "Current PeerID value is '#{current_value}'"

      if (current_value.eql?(@peer_id.to_s))
        @log.info "Requested value is already set, no need to update, skipping."
      else
        @log.info "Updating to '#{@peer_id}'..."

        @log.debug "Stopping ServerPeer service..."
        twiddle_execute( "invoke jboss.messaging:service=ServerPeer stop" )
        @log.debug "Service stopped."
        twiddle_execute( "set jboss.messaging:service=ServerPeer ServerPeerID #{@peer_id}" )
        @log.debug "Starting ServerPeer service..."
        twiddle_execute( "invoke jboss.messaging:service=ServerPeer start" )
        @log.debug "Service started."
        @log.info "PeerID updated."
      end

      false
    end

    def load_peer_id
      if @mgmt_address.nil?
        @log.error "No management appliance address specified, cannot get PeerId."
        return false
      end

      @peer_id = @client_helper.get( "http://#{@mgmt_address}:#{MANAGEMENT_PORT}/latest/peer-id" )

      if @peer_id.nil?
        @log.error "Received PEER_ID = #{@peer_id} is not valid."
        return false
      end
      true
    end
  end
end
