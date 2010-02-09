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

require 'cirras-management/helper/config-helper'
require 'cirras-management/model/node'

module CirrASManagement
  class Config
    def initialize( fields )

      fields.each_pair do | key, value |
        instance_variable_set("@#{key}", value)
      end

      @observers        = []
      @port             = 4545          # port used to listen on
      @timeout          = 2             # time to wait for response from other node (in seconds)
      @sleep            = 20            # time to wait before next node querying
    end

    attr_reader :rack_config
    attr_reader :running_on_ec2
    attr_reader :port
    attr_reader :timeout
    attr_reader :sleep
    attr_reader :leases_file
    attr_reader :node

    attr_accessor :appliance_name

    def is_management_appliance?
      @appliance_name.eql?(APPLIANCE_TYPE[:management])
    end

  end
end