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

require 'cirras-management/node/base-node-manager'

module CirrASManagement
  class DefaultNodeManager < BaseNodeManager
    def initialize( config, options = {} )
      super( config, options )

      @leases_file  = @config.leases_file
    end

    def node_addresses
      addresses = []

      # if this is not EC2
      log_msg = "Package dhcpd isn't installed or DHCP server isn't running. Aborting."

      unless File.exists?( @leases_file )
        @log.fatal log_msg
        raise log_msg
      end

      # get IP addresses from lease file
      lease_ips = `grep -B 5 "binding state active" #{@leases_file} | grep lease | awk '{ print $2 }'`

      # parsing file
      lease_ips.each { |line| addresses.push line.strip }

      # push our local IP too
      addresses.push @ip_helper.local_ip

      addresses.uniq
    end
  end
end