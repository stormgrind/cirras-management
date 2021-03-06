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

require 'cirras-management/helper/exec-helper'
require 'cirras-management/helper/ip-helper'
require 'cirras-management/defaults'
require 'nokogiri'

module CirrASManagement
  class RHQAgentUpdateCommand
    def initialize( agent_options, options = {} )
      @log                        = options[:log]                       || Logger.new(STDOUT)
      @rhq_agent_sysconf_file     = options[:rhq_agent_sysconf_file]    || RHQ_AGENT_SYSCONF_FILE
      @exec_helper                = options[:exec_helper]               || ExecHelper.new( { :log => @log } )
      @ip_helper                  = options[:ip_helper]                 || IPHelper.new( { :log => @log } )

      @appliance_name             = agent_options[:appliance_name]
      @mgmt_address               = agent_options[:management_appliance_address]
    end

    def execute
      unless load_configuration
        @log.error "Couldn't load configuration for RHQ Agent, check logs for errors."
        return
      end

      update_entry( 'rhq.agent.name', "#{@appliance_name}#{@appliance_name.nil? ? "" : "-"}#{Socket.gethostname}" )
      update_entry( 'rhq.agent.server.bind-address', @mgmt_address )

      update_file
      restart_agent
    end

    def update_file
      File.open(@agent_configuration_file, 'w') {|f| @agent_configuration.write_xml_to f}
    end

    def load_configuration
      unless File.exists?(@rhq_agent_sysconf_file)
        @log.error "System configuration file for RQH Agent: #{@rhq_agent_sysconf_file} not found."
        return false
      end

      @agent_configuration_file = "#{File.read(@rhq_agent_sysconf_file).scan(/^RHQ_AGENT_HOME=(.*)$/).to_s}/conf/agent-configuration.xml"

      unless File.exists?( @agent_configuration_file )
        @log.error "Configuration file for RQH Agent: #{@agent_configuration_file} not found."
        return false
      end

      begin
        @agent_configuration = Nokogiri::XML(File.new(@agent_configuration_file))
        @entry_map           = get_entries_by_key('rhq.agent.configuration-schema-version').first.parent

        return true
      rescue => e
        @log.error "Couldn't load agent configuration file or find required <map> entry."
        @log.error e

        return false
      end
    end

    def update_entry( key, value )
      entries = get_entries_by_key( key )

      if entries.size == 0
        # just adding
        entry = Nokogiri::XML::Node.new( "entry", @agent_configuration )
        entry['key']    = key
        entry['value']  = value

        @entry_map.add_child(entry)
      else
        # we need to update existing value
        entries.each do |entry|
          entry['value'] = value
        end
      end

    end

    def get_entries_by_key( key )
      @agent_configuration.xpath("//entry[@key='#{key}']")
    end

    def restart_agent
      @log.info "Restarting RHQ Agent..."

      begin
        @exec_helper.execute "service rhq-agent restart --update"
        @log.info "RHQ Agent successfully restarted."
        return true
      rescue => e
        @log.error "Couldn't restart RHQ agent."
        @log.error e
        return false
      end
    end
  end
end