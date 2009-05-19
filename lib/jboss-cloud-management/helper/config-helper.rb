require 'jboss-cloud-management/helper/ip-helper'
require 'jboss-cloud-management/helper/log-helper'
require 'restclient'

module JBossCloudManagement
  class ConfigHelper
    def initialize
      @log = LogHelper.instance.log
    end

    def is_ec2?
      @log.info "Discovering if we're on EC2..."

      is_ec2 = false

      begin
        # trying to get local IP on EC2
        RestClient.get 'http://169.254.169.254/latest/meta-data/local-ipv4'
        is_ec2 = true
      rescue
      end

      if is_ec2
        @log.info "We're on EC2!"
      else
        @log.info "We're not on EC2!"
      end

      is_ec2
    end

  end
end