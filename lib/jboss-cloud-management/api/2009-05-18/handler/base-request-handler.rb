module JBossCloudManagement
  class BaseRequestHandler
    def initialize( prefix, config )
      @prefix   = prefix
      @config   = config

      define_handle
    end

    attr_reader :prefix

    def define_handle
      raise "NotImplemented"
    end
  end
end
