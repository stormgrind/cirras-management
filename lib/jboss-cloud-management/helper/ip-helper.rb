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

require 'net/http'
require 'uri'
require 'socket'
require 'timeout'
require 'ping'
require 'yaml'
require 'rubygems'

module JBossCloudManagement
  class IPHelper

    def initialize
      @timeout = 2
    end

    def local_ip
      address = `ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1`.strip
      return nil if address.length == 0
      address
    end

    def is_port_open?(ip, port = 80)
      begin
        Timeout::timeout(@timeout) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
      end

      return false
    end

  end
end
