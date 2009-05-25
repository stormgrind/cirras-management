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
          data = YAML.load( Base64.decode64( RestClient.get( url ).to_s ))

          return nil if data == false
          return data
        end
      rescue StandardError => err
        @log.warn "An error occured: #{err}"
      end
      nil
    end

    def put( url, data )
      begin
        Timeout::timeout(@config.timeout) do
          RestClient.put( url, data )
        end
      rescue StandardError => err
        @log.warn "An error occured: #{err}"
      end
    end
  end
end
