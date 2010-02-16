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
  class UpdateProxyListCommand < BaseJBossASCommand
    def initialize( management_appliance_address, options = {} )
      super( { :log => options[:log] } )

      @management_appliance_address = management_appliance_address
    end
    def execute
      unless load_front_end_list
        @log.error "Proxy list in JBoss AS instance wasn't updated, check logs."
        return
      end

      current_proxies = get_current_proxies
      current_hosts = current_proxies.keys

      # first of all, remove old proxies
      for host in current_hosts
        unless @proxies.include?(host)
          remove_proxy( host, current_proxies[host][:port] )
        end
      end

      # now we need to add new proxies or update ports
      for host in @proxies
        if current_hosts.include?(host)
          unless current_proxies[host][:port].eql?(DEFAULT_FRONT_END_PORT)
            @log.info "Proxy for host #{current_proxies[host][:host]} needs to be updated because port has changed from #{current_proxies[host][:port]} to #{DEFAULT_FRONT_END_PORT}, updating..."
            remove_proxy( current_proxies[host][:host], current_proxies[host][:port] )
            add_proxy( host, DEFAULT_FRONT_END_PORT )
            @log.info "Proxy updated."
          end
        else
          @log.info "Adding new proxy #{host}:#{DEFAULT_FRONT_END_PORT}..."
          add_proxy( host, DEFAULT_FRONT_END_PORT )
          @log.info "Proxy added."
        end
      end
    end

    def load_front_end_list
      if (@management_appliance_address.nil?)
        @log.error "No management appliance address specified, cannot get front-end addresses."
        return false
      end

      @log.info "Asking for front-end appliance address list..."

      @proxies = @client_helper.get( "http://#{@management_appliance_address}:4545/latest/address/#{APPLIANCE_TYPE[:frontend]}" )

      if @proxies.nil? or !@proxies.is_a?(Array)
        @log.error "Got no valid response from management-appliance!"
        return false
      end

      true
    end

    def get_current_proxies
      @log.debug "Loading proxy list from JBoss AS..."

      proxy_info  = twiddle_execute( "get jboss.web:service=ModCluster ProxyInfo" ).scan(/\/(\d+\.\d+\.\d+\.\d+):(\d+)=/)
      proxies     = {}

      proxy_info.each  do |proxy|
        proxies[proxy[0]] = { :host => proxy[0], :port => proxy[1].to_i }
      end

      @log.debug "Loaded #{proxies.size} proxies."

      proxies
    end

    def add_proxy( host, port )
      @log.info "Adding new proxy to JBoss AS: #{host}:#{port}..."
      twiddle_execute( "invoke jboss.web:service=ModCluster addProxy #{host} #{port}" )
      @log.info "Proxy #{host}:#{port} added."
    end

    def remove_proxy( host, port )
      @log.info "Removing proxy from JBoss AS: #{host}:#{port}..."
      twiddle_execute( "invoke jboss.web:service=ModCluster removeProxy #{host} #{port}" )
      @log.info "Proxy #{host}:#{port} removed."
    end
  end
end
