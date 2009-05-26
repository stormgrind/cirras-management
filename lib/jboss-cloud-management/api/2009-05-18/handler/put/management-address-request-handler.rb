require 'jboss-cloud-management/api/2009-05-18/handler/base-request-handler'
require 'jboss-cloud-management/helper/log-helper'
require 'jboss-cloud-management/helper/client-helper'

module JBossCloudManagement
  class ManagementAddressRequestHandler < BaseRequestHandler
    def initialize( path, to )
      super( path, to )

      @client_helper = ClientHelper.new( @config, @log )
      @jboss_as5_conf_file = "/etc/jboss-as5.conf"
    end

    attr_accessor :client_helper
    attr_accessor :jboss_as5_conf_file

    def management_address_request( address )
      @log.info "Got new management-appliance address: #{address}"

      case @config.appliance_name
        when APPLIANCE_TYPE[:backend]
          # if we're a back-end appliance, ask for front-end appliance address to inject it to /etc/jboss-as5.conf

          @log.info "Asking for front-end appliance address..."

          front_end_addresses = @client_helper.get( "http://#{address}:#{@config.port}/latest/address/#{APPLIANCE_TYPE[:frontend]}" )

          if front_end_addresses.nil? or !front_end_addresses.class.eql?(Array)
            @log.warn "Got no valid response from management-appliance!"
            return
          end

          if front_end_addresses.size == 0
            @log.info "No front-end appliances running, skipping."

            Thread.new do
              jboss_stop
            end

            return
          end

          front_end_address = front_end_addresses.first

          if @front_end_address != front_end_address
            @front_end_address = front_end_address

            @log.info "Injecting front-and appliance address #{@front_end_address} to '#{jboss_as5_conf_file}'..."
            # inject front-end appliance address to /etc/jboss-as5.conf

            unless File.exists?( @jboss_as5_conf_file )
              @log.error "File #{@jboss_as5_conf_file} does not exists! Injecting front-end appliance address failed."
              return
            end

            jboss_as5_conf  = File.read( @jboss_as5_conf_file )

            pattern_proxy   = /^JBOSS_PROXY_LIST=(.*)/
            pattern_gossip  = /^JBOSS_GOSSIP_HOST=(.*)/

            matches_proxy   = jboss_as5_conf.match( pattern_proxy )
            matches_gossip  = jboss_as5_conf.match( pattern_gossip )

            directive_proxy   = "JBOSS_PROXY_LIST=#{@front_end_address}:80"
            directive_gossip  = "JBOSS_GOSSIP_HOST=#{@front_end_address}"

            if matches_proxy.nil?
              # no JBOSS_PROXY_LIST line, adding one
              jboss_as5_conf += "\n\n#{directive_proxy}"
            else
              jboss_as5_conf.gsub!( pattern_proxy, directive_proxy  )
            end

            if matches_gossip.nil?
              # no JBOSS_GOSSIP_HOST line, adding one
              jboss_as5_conf += "\n\n#{directive_gossip}"
            else
              jboss_as5_conf.gsub!( pattern_gossip, directive_gossip  )
            end

            `sudo sh -c "echo '#{jboss_as5_conf}' > #{@jboss_as5_conf_file}"`

            Thread.new do
              jboss_stop
              jboss_start
            end
          end
        else

      end

    end

    def jboss_stop
      @log.info "Stopping jboss-as5 service..."
      `sudo /sbin/service jboss-as5 stop`

      unless $?.to_i == 0
        @log.error "Service jboss-as5 stopping failed or jboss-as5 was not running."
      else
        @log.info "Service jboss-as5 successfully stopped."
      end
    end

    def jboss_start
      @log.info "Starting jboss-as5 service..."
      `sudo /sbin/service jboss-as5 start`

      unless $?.to_i == 0
        @log.error "Service jboss-as5 starting failed. Check system logs."
      else
        @log.info "Service jboss-as5 successfully started."
      end
    end

    def define_handle
      put @path do
        pass if params[:address].nil?

        notify( :management_address_request, params[:address].strip )
      end
    end
  end
end
