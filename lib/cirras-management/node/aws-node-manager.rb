# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'EC2'
require 'cirras-management/node/base-node-manager'

module CirrASManagement
  class AWSNodeManager < BaseNodeManager
    def initialize( config, options = {} )
      super( config, options )

      @aws_data = {}

      get_aws_data
      validate_aws_config

      @ec2 = EC2::Base.new(:access_key_id => @aws_data['access_key'], :secret_access_key => @aws_data['secret_access_key'])
      # just for test if credentials are valid
      @ec2.describe_availability_zones
    end

    attr_reader :aws_data

    def get_aws_data
      @aws_data = @client_helper.get( "http://169.254.169.254/latest/user-data" )    
    end

    def validate_aws_config
      raise "Please provide access keys as user data while launching this AMI. You must relaunch this AMI with valid user data." if @aws_data.nil?
      raise "Please provide access key as user data while launching this AMI: access_key: YOUR_ACCESS_KEY" if @aws_data['access_key'].nil?
      raise "Please provide secret access key as user data while launching this AMI: secret_access_key: YOUR_SECRET_ACCESS_KEY" if @aws_data['secret_access_key'].nil?
      raise "Please provide bucket name to store cluster topology information as user data while launching this AMI: bucket: BUCKET/LOCATION" if @aws_data['bucket'].nil?
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
