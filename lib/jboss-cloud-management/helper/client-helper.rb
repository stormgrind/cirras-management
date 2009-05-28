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

require 'yaml'
require 'base64'

module JBossCloudManagement
  class ClientHelper
    def initialize( config, log )
      @config     = config
      @log        = log

    end

    def get( url )
      begin
        Timeout::timeout(@config.timeout) do
          data = YAML.load( Base64.decode64( RestClient.get( url ).to_s ))

          return nil if data == false
          return data
        end
      rescue StandardError => err
        @log.warn "An error occured: #{err}"
      end
      nil
    end

    def put( url, data )
      begin
        Timeout::timeout(@config.timeout) do
          RestClient.put( url, data )
        end
      rescue StandardError => err
        @log.warn "An error occured: #{err}"
      end
    end
  end
end
