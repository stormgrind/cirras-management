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

require 'logger'
require 'singleton'
require 'cirras-management/defaults'

module CirrASManagement
  class LogHelper
    include Singleton

    def initialize
      @log              = Logger.new(LOG_DEFAULT_FILE, 10, 1024000)
      @log.level        = Logger::DEBUG
      @web_log          = Logger.new(LOG_WEB_FILE, 10, 1024000)
      @client_log_file  = LOG_CLIENT_FILE
    end

    attr_reader :log
    attr_reader :web_log
    attr_reader :client_log_file

  end
end