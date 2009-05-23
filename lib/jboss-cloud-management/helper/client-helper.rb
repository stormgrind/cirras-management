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
          data = YAML.load( Base64.b64decode( RestClient.get( url ).to_s ))

          return nil if data == false
          return data
        end
      rescue Timeout::Error
        @log.warn "We don't have any response for #{url} in #{@config.timeout} seconds for GET request."
      end
      nil
    end

    def put( url, data )
      begin
        Timeout::timeout(@config.timeout) do
          RestClient.put( url, data )
        end
      rescue Timeout::Error
        @log.warn "We don't have any response for #{url} in #{@config.timeout} seconds for PUT request."
      end
    end
  end
end
