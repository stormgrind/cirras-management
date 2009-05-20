module JBossCloudManagement
  class ClientHelper
    def initialize( config )
      @config     = config
      @log        = LogHelper.instance.log

    end

    def get( url, address )
      begin
        Timeout::timeout(@config.timeout) do
          return RestClient.get( url )
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
