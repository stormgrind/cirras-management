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

require 'cirras-management/api/commands/base-jboss-as-command'
require 'cirras-management/helper/client-helper'
require 'cirras-management/helper/string-helper'

module CirrASManagement
  class UpdateS3PingCredentialsCommand < BaseJBossASCommand

    ACCESS_KEY        = 'JBOSS_JGROUPS_S3_PING_ACCESS_KEY'
    SECRET_ACCESS_KEY = 'JBOSS_JGROUPS_S3_PING_SECRET_ACCESS_KEY'
    BUCKET            = 'JBOSS_JGROUPS_S3_PING_BUCKET'

    def initialize( options = {} )
      @log             = options[:log]            || Logger.new(STDOUT)
      @client_helper   = options[:client_helper]  || ClientHelper.new( { :log => @log } )
      @string_helper   = options[:string_helper]  || StringHelper.new( { :log => @log } )
      @mgmt_address    = options[:mgmt_address]
    end

    attr_reader :restart

    def execute
      unless load_aws_credentials
        @log.error "AWS credentials could not be loaded"
        return
      end

      @log.debug "Reading JBoss AS config file..."
      @jboss_config = File.read(JBOSS_SYSCONFIG_FILE)

      unless (read_credentials == @aws_credentials)
        write_credentials
        return true
      end

      @log.debug "Current and new AWS credentials are same, skipping..."

      false
    end

    def write_credentials
      @log.info "Writing new AWS credentials to JBoss AS config file..."

      @string_helper.update_config( @jboss_config, ACCESS_KEY, @aws_credentials['access_key'] )
      @string_helper.update_config( @jboss_config, SECRET_ACCESS_KEY, @aws_credentials['secret_access_key'] )
      @string_helper.update_config( @jboss_config, BUCKET, @aws_credentials['bucket'] )

      @string_helper.add_new_line(@jboss_config)

      File.open(JBOSS_SYSCONFIG_FILE, 'w') {|f| f.write(@jboss_config) }
    end

    def read_credentials
      @log.debug "Reading AWS credentials from config file..."

      credentials = {}

      credentials['access_key']        = @string_helper.prop_value( @jboss_config, ACCESS_KEY )
      credentials['secret_access_key'] = @string_helper.prop_value( @jboss_config, SECRET_ACCESS_KEY )
      credentials['bucket']            = @string_helper.prop_value( @jboss_config, BUCKET )

      credentials
    end

    def load_aws_credentials
      if (@mgmt_address.nil?)
        @log.error "No management appliance address specified."
        return false
      end

      @log.info "Asking for AWS credentials..."

      @aws_credentials = @client_helper.get( "http://#{@mgmt_address}:#{MANAGEMENT_PORT}/latest/awscredentials" )

      if @aws_credentials.nil? or !@aws_credentials.is_a?(Hash)
        @log.error "Got no valid response from management-appliance!"
        return false
      end

      true
    end
  end
end
