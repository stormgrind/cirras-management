require 'jboss-cloud-management/node/base-node-manager'

module JBossCloudManagement
  class AWSNodeManager < BaseNodeManager
    def initialize( config )
      super( config )

      @ec2_config_file = "/home/thin/.jboss-cloud/ec2"

      validate_aws_config

      @ec2 = EC2::Base.new(:access_key_id => @aws_data['access_key'], :secret_access_key => @aws_data['secret_access_key'])
      # just for test if credentials are valid
      @ec2.describe_availability_zones
    end

    def validate_aws_config
      raise "Configuration file #{@ec2_config_file}, doesn't exists. Please create it."  unless File.exists?( @ec2_config_file )

      @aws_data = YAML.load_file( @ec2_config_file )

      raise "Invalid configuration file #{@ec2_config_file}, please check structure of this file." unless @aws_data
      raise "Please specify access key in aws section in configuration file #{@ec2_config_file}: access_key: YOUR_ACCESS_KEY" if @aws_data['access_key'].nil?
      raise "Please specify secret access key in aws section in configuration file #{@ec2_config_file}: secret_access_key: YOUR_SECRET_ACCESS_KEY" if @aws_data['secret_access_key'].nil?
    end

    def node_addresses
      addresses = []

      begin
        instances = @ec2.describe_instances
      rescue
        log_msg = "No running instances?! WTF? At least our instance should be in instance list! Aborting."

        @log.error log_msg
        raise log_msg
      end

      for reservation in instances.reservationSet.item
        for instance in reservation.instancesSet.item
          addresses.push( instance.privateDnsName.strip )
        end
      end

      addresses
    end

  end
end
