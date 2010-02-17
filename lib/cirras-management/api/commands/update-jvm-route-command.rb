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
  class UpdateJVMRouteCommand < BaseJBossASCommand

    def initialize( options = {} )
      super( { :log => options[:log] } )
    end

    def execute
      unless calculate_jvm_route
        @log.error "Couldn't calculate JVMRoute, check logs for errors."
        return
      end

      current_jvm_route = twiddle_execute( "get jboss.web:type=Engine jvmRoute" ).scan(/^jvmRoute=(.*)$/).to_s

      @log.info "Current JVMRoute value is '#{current_jvm_route}'"

      if (current_jvm_route.eql?(@jvm_route))
        @log.info "Requested value is already set, no need to update, skipping."
      else
        @log.info "Updating to '#{@jvm_route}'..."
        twiddle_execute( "set jboss.web:type=Engine jvmRoute #{@jvm_route}" )
        @log.info "JVMRoute updated."
      end

      false
    end

    def calculate_jvm_route
      ip_address  = @ip_helper.local_ip
      return false if ip_address.nil?

      @jvm_route = "#{Socket.gethostname}-#{ip_address}"

      true
    end
  end
end
