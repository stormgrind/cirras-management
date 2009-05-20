require 'singleton'

module JBossCloudManagement
  class EventManager
    include Singleton

    def initialize
      @event_handlers   = {}
      @log              = LogHelper.instance.log
    end

    def register( event, handler )
      @event_handlers[event] = [] if @event_handlers[event].nil?
      @event_handlers[event].push handler
    end

    def notify( event, *args )
      unless @event_handlers[event].nil?
        @log.debug "Handling event #{event}..."
        @event_handlers[event].each do |handler|
          @log.debug "Notyfing handler #{handler}"
          handler.send event, *args
        end
        @log.debug "Event #{event} finished"
      else
        @log.debug "No handlers for event #{event}"
      end
    end
  end
end