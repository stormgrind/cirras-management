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
      @log.debug "Event #{event} raised!"
      @event_handlers[event].each do |handler|
        handler.send event, *args
      end unless @event_handlers[event].nil?
    end

  end
end