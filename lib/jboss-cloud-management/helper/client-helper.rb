require 'yaml'

module JBossCloudManagement
  class ClientHelper
    def initialize( config, log )
      @config     = config
      @log        = log

    end

    def get( url, address )
      begin
        Timeout::timeout(@config.timeout) do
          data = YAML.load( RestClient.get( url ) )

          return nil if data == false
          return data
        end
      rescue Timeout::Error
        @log.warn "Node #{address} hasn't replied in #{@config.timeout} seconds for GET request on #{address}."
      end
      nil
    end

    def put( url, address, data )
      begin
        Timeout::timeout(@config.timeout) do
          RestClient.put( url, data )
        end
      rescue Timeout::Error
        @log.warn "Node #{address} hasn't replied in #{@config.timeout} seconds for PUT request on #{address}."
      end
    end
  end
end
