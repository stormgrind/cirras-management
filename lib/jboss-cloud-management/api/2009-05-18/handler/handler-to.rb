module JBossCloudManagement
  class HandlerTO
    def initialize( prefix, api_version, config, log )
      @prefix       = prefix
      @api_version  = api_version
      @config       = config
      @log          = log
    end

    attr_reader :prefix
    attr_reader :api_version
    attr_reader :log
    attr_reader :config
    attr_reader :log
  end
end