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

require 'cirras-management/helper/ip-helper'
require 'cirras-management/helper/log-helper'
require 'restclient'

module CirrASManagement
  class ConfigHelper
    def initialize( log )
      @log = log
    end

    def is_ec2?
      @log.info "Discovering if we're on EC2..."

      is_ec2 = false

      begin
        # trying to get local IP on EC2
        RestClient.get 'http://169.254.169.254/latest/meta-data/local-ipv4'
        is_ec2 = true
      rescue
      end

      if is_ec2
        @log.info "We're on EC2!"
      else
        @log.info "We're not on EC2!"
      end

      is_ec2
    end

  end
end