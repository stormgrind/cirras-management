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
require 'cirras-management/helper/client-helper'
require 'cirras-management/helper/ip-helper'
require 'cirras-management/defaults'

module CirrASManagement
  class BaseJBossASCommand
    def initialize( options = {} )
      @log            = options[:log]           || Logger.new(STDOUT)
      @exec_helper    = options[:exec_helper]   || ExecHelper.new( { :log => @log } )
      @client_helper  = options[:client_helper] || ClientHelper.new( { :log => @log } )
      @ip_helper      = options[:ip_helper]     || IPHelper.new( { :log => @log } )
    end

    def twiddle_execute( command )
      @log.debug "Executing '#{command}' using Twiddle..."
      out = @exec_helper.execute("#{JBOSS_HOME}/bin/twiddle.sh -s #{Socket.gethostname} -u admin -p admin #{command}")
      @log.debug "Command executed."
      out
    end
  end
end