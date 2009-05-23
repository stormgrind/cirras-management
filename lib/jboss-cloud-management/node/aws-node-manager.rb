require 'EC2'
require 'jboss-cloud-management/node/base-node-manager'

module JBossCloudManagement
  class AWSNodeManager < BaseNodeManager
    def initialize( config )
      super( config )

      @aws_data = {}

      get_aws_data
      validate_aws_config

      @ec2 = EC2::Base.new(:access_key_id => @aws_data['access_key'], :secret_access_key => @aws_data['secret_access_key'])
      # just for test if credentials are valid
      @ec2.describe_availability_zones
    end

    def get_aws_data
      data = @client_helper.get( "http://169.254.169.254/latest/user-data" )

      unless data.nil? and data.class.eql?(Hash)
        @aws_data = data
      end
     
    end

    def validate_aws_config
      raise "Please provide access key as user data while launching thi AMI: access_key: YOUR_ACCESS_KEY" if @aws_data['access_key'].nil?
      raise "Please provide secret access key as user data while launching thi AMI: secret_access_key: YOUR_SECRET_ACCESS_KEY" if @aws_data['secret_access_key'].nil?
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
          addresses.push( instance.privateDnsName.strip ) if instance.instanceState.name.eql?('running')
        end
      end

      addresses
    end

  end
end
