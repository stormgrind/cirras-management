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

module CirrASManagement
  class ReconfigureRHQAgentCommand < BaseJBossASCommand

    def initialize( management_appliance_address, options = {} )
      super( { :log => options[:log] } )

      @management_appliance_address = management_appliance_address
    end

    def execute
      if @management_appliance_address.nil?
        @log.warn "No management appliance provided, skipping reconfiguring RHQ Agent."
        return
      end

      # we're assuming that on back-end node rhq-agent package is installed
      @exec_helper.execute "sudo sh -c \"echo 'RHQ_SERVER_IP=#{@management_appliance_address}' >> /etc/sysconfig/rhq-agent\""

      # TODO: remove this, what with reconfiguring?
      stop_rhq_agent
      start_rhq_agent
    end

    def start_rhq_agent
      @log.info "Starting RHQ agent..."
      @exec_helper.execute "sudo /sbin/service rhq-agent start"
    end

    def stop_rhq_agent
      @log.info "Stopping RHQ agent..."
      @exec_helper.execute "sudo /sbin/service rhq-agent stop"
    end
  end
end
