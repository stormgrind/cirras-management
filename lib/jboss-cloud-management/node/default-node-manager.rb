require 'jboss-cloud-management/node/base-node-manager'

module JBossCloudManagement
  class DefaultNodeManager < BaseNodeManager
    def initialize( config )
      super( config )
      @leases_file  = "./leases" # "/var/lib/dhcpd/dhcpd.leases"
    end

    def node_addresses
      addresses = []

      # if this is not EC2
      log_msg = "Package dhcpd isn't installed or DHCP server isn't running. Aborting."

      unless File.exists?( @leases_file )
        @log.fatal log_msg
        raise log_msg
      end

      # get IP addresses from lease file
      lease_ips = `grep -B 3 "binding state active" #{@leases_file} | grep lease | awk '{ print $2 }'`

      # parsing file
      lease_ips.each { |line| addresses.push line.strip }

      addresses
    end
  end
end