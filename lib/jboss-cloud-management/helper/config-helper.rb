require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/helper/log-helper'

module JBossCloudManagement
  class ConfigHelper
    def initialize
      @ip_helper  = IPHelper.new
      @log        = LogHelper.instance.log
    end

    def is_ec2?
      @log.info "Discovering if we're on EC2..."
      is_ec2 = @ip_helper.is_port_open?( "169.254.169.254" )

      if is_ec2
        @log.info "We're on EC2!"
      else
        @log.info "We're not on EC2!"
      end

      is_ec2
    end

  end
end