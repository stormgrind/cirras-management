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
require 'logger'
require 'rubygems'
require 'restclient'

module CirrASManagement
  class ClientHelper
    def initialize( options = {} )
      @timeout    = options[:timeout]   || 2
      @log        = options[:log]       || Logger.new(STDOUT)
    end

    def get( url, plain = false )
      @log.debug "GET: #{url}"

      t_current = Thread.current
      begin
        t_timer = Thread.new { sleep @timeout; t_current.raise "Timeout exceeded while getting information from url '#{url}'" }

        raw = RestClient.get( url )

        return raw if plain

        base64_decoded  = Base64.decode64( raw.to_s )
        data            = YAML.load( base64_decoded )

        return nil if data == false
        return data
      rescue StandardError => err
        @log.warn "An error occured: #{err}"
      ensure
        t_timer.kill
      end
      nil
    end

    def put( url, data )
      @log.debug "PUT: #{url}, #{data}"

      t_current = Thread.current
      begin
        t_timer = Thread.new { sleep @timeout; t_current.raise "Timeout exceeded while putting information to url '#{url}'" }

        RestClient.put( url, data )
      rescue StandardError => err
        @log.warn "An error occured: #{err}"
      ensure
        t_timer.kill
      end
    end
  end
end
