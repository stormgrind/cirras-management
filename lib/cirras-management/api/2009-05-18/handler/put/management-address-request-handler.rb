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

require 'cirras-management/api/2009-05-18/handler/base-request-handler'
require 'cirras-management/helper/log-helper'
require 'cirras-management/helper/client-helper'
require 'cirras-management/api/commands/update-rhq-agent-command'
require 'cirras-management/api/commands/jboss-command-factory'

module CirrASManagement
  class ManagementAddressRequestHandler < BaseRequestHandler

    def initialize( path, to )
      super( path, to )

      @environment            = @config.running_on_ec2 ? :ec2 : :default
      @back_end_cmds_running  = false
    end

    def management_address_request( management_appliance_address )
      @log.info "Got new management appliance address: #{management_appliance_address}"

      begin
        case @config.appliance_name
          when APPLIANCE_TYPE[:backend]
            # TODO: this should be moved from here and executed periodically we should only update here management appliance address.

            unless @back_end_cmds_running
              @back_end_cmds_running = true
              begin
                JBossCommandFactory.new( :log => @log, :mgmt_address => management_appliance_address, :environment => @environment ).execute
              rescue => e
                @log.error e
                @log.error "An error occurred, see logs."
              end

              @back_end_cmds_running = false
            else
              @log.debug "Another set of JBoss AS commands is being executed, skipping..."
            end
        end

        if @management_address != management_appliance_address
          @management_address = management_appliance_address

          RHQAgentUpdateCommand.new({
                  :appliance_name => @config.appliance_name,
                  :management_appliance_address => @management_address
          }).execute
        end
      rescue => e
        @log.error "Something bad happened, but it shouldn't..."
        @log.error e
      end
    end

    def is_jboss_running?

    end

    def define_handle
      put @path do
        pass if params[:address].nil?

        notify_threaded( :management_address_request, params[:address].strip )
      end
    end
  end
end
