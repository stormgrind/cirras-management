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

require 'singleton'

module CirrASManagement
  class EventManager
    include Singleton

    def initialize
      @event_handlers   = {}
      @log              = LogHelper.instance.log
    end

    def register( api_version, prefix, handlers )
      @log.debug "Registering handlers for API version #{api_version} and prefix #{prefix}..."

      handlers.each do |event, array|
        array.each do |h|
          @log.debug "Registering handler #{h.class} for event #{event}"
          unless h.respond_to? event
            raise NoMethodError, "Handler #{h.class} does not have method `#{event.to_s}'"
          end
        end
      end

      @event_handlers[prefix] = handlers

      @log.debug "Registered #{handlers.size} handler helpers for API version '#{api_version}' and prefix '#{prefix}'"
    end

    def notify( threaded, prefix, event, *args )
      return if @event_handlers[prefix].nil?

      unless @event_handlers[prefix][event].nil?
        if threaded
          Thread.new do
            notify_internal( prefix, event, *args )
          end
        else
          notify_internal( prefix, event, *args )
        end
      else
        @log.debug "No handlers for event #{event}"
      end
    end

    protected

    def notify_internal( prefix, event, *args )
      @log.debug "Handling event #{event} for prefix #{prefix}..."
      @event_handlers[prefix][event].each do |handler|
        @log.debug "Notifying handler #{handler.class}"
        handler.send event, *args
      end
      @log.debug "Event #{event} was successfully handled"
    end
  end
end