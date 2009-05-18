module JBossCloudManagement
  class BaseRequestHandler
    def initialize( prefix )
      @prefix   = prefix

      define_handle
    end

    attr_reader :prefix

    def define_handle
      raise "NotImplemented"
    end
  end
end
