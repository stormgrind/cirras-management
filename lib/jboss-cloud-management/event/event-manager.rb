require 'singleton'

module JBossCloudManagement
  class EventManager
    include Singleton

    def initialize
      @event_handlers   = {}
      @log              = LogHelper.instance.log
    end

    def register( api_version, prefix, handlers )
      @log.debug "Registering handlers for API version #{api_version} and prefix #{prefix}..."

      handlers.each { |event, handler| @log.debug "Registering handler #{handler.class} for event #{event}" }

      @event_handlers[prefix] = handlers
    end

    def notify( prefix, event, *args )
      return if @event_handlers[prefix].nil?

      unless @event_handlers[prefix][event].nil?
        @log.debug "Handling event #{event} for prefix #{prefix}..."
        @event_handlers[prefix][event].each do |handler|
          @log.debug "Notyfing handler #{handler.class}"
          handler.send event, *args
        end
        @log.debug "Event #{event} was successfuly handled"
      else
        @log.debug "No handlers for event #{event}"
      end
    end
  end
end