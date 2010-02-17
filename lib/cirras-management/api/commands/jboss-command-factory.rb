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

require 'cirras-management/api/commands/update-jvm-route-command'
require 'cirras-management/api/commands/update-proxy-list-command'
require 'cirras-management/api/commands/update-gossip-host-address-command'
require 'cirras-management/api/commands/update-peer-id-command'
require 'cirras-management/api/commands/update-s3ping-credentials-command'

module CirrASManagement
  class JBossCommandFactory

    COMMANDS = {
            :running => {
                    :default  => [ UpdatePeerIdCommand, UpdateProxyListCommand, UpdateJVMRouteCommand ]
            },
            :default  => [ UpdateGossipHostAddressCommand ],
            :ec2      => [ UpdateS3PingCredentialsCommand ]
    }

    def initialize( options = {} )
      @log              = options[:log]           || Logger.new(STDOUT)
      @exec_helper      = options[:exec_helper]   || ExecHelper.new( { :log => @log } )
      @ip_helper        = options[:ip_helper]     || IPHelper.new( { :log => @log } )
      @mgmt_address     = options[:mgmt_address]
      @environment      = options[:environment]
      @restart          = false
    end

    def execute
      @log.debug "Executing commands for #{@environment.to_s.upcase} environment..."
      execute_commands(COMMANDS[@environment])
      @log.debug "Default commands executed."

      unless COMMANDS[:running][@environment].nil?
        unless is_jboss_running?
          @restart = false
          # start JBoss and wait for boot
          start_jboss
        end

        @log.debug "Executing commands for #{@environment.to_s.upcase} environment ..."
        execute_commands(COMMANDS[:running][@environment])
      end

      unless is_jboss_running?
        start_jboss
      else
        restart_jboss if @restart
      end
    end

    def execute_commands( commands )
      commands.each do |cmd|
        @log.debug "Executing #{cmd.class}..."
        @restart = true if cmd.new( :log => @log, :mgmt_address => @mgmt_address ).execute
        @log.debug "Command #{cmd.class} executed."
      end
    end

    def is_jboss_running?
      pids = @exec_helper.execute("pidof -x '/bin/sh'")

      pids.each(" ") { |pid| return true if `ps -fp #{pid.strip} | grep 'org.jboss.Main' | grep '#{@ip_helper.local_ip}'`.length > 0 }
      false
    end

    def start_jboss
      @log.debug "Starting JBoss AS..."
      @exec_helper.execute("service #{JBOSS_SERVICE_NAME} start")
      @log.debug "JBoss AS started"
    end

    def restart_jboss
      @log.debug "Restarting JBoss AS..."
      @exec_helper.execute("service #{JBOSS_SERVICE_NAME} restart")
      @log.debug "JBoss AS restarted"
    end
  end
end