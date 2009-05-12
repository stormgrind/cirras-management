require 'rubygems'
require 'restclient'
require 'timeout'
require 'jboss-cloud-management/helper/log-helper'

module JBossCloudManagement
  class Client
    def initialize( ip, config )
      #RestClient.log = 'stdout'
      @log        = LogHelper.instance.log
      @ip         = ip
      @config     = config
      @resource   = "http://#{@ip}:#{@config.port}"
      @ip_helper  = IPHelper.new
    end

    def get_info
      @log.info "Getting info from node #{@ip}..."

      if @ip_helper.is_port_open?( @ip, @config.port )
        return get( "#{@resource}/info" )
      else
        @log.warn "Port #{@config.port} is closed on #{@ip}, ignoring."
      end
      nil
    end

    def get( url )
      begin
        Timeout::timeout(@config.timeout) do
          return RestClient.get( url )
        end
      rescue Timeout::Error
        @log.warn "Node #{@ip} hasn't replied in #{@config.timeout} seconds for GET request on #{url}."
      end
      nil
    end

  end
end


