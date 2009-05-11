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

require 'net/http'
require 'uri'
require 'socket'
require 'timeout'
require 'ping'
require 'yaml'
require 'rubygems'
require 'EC2'
require 'logger'

module JBossCloudManagement
  class IPHelper

    def initialize
      @leases_file        = "./leases" # "/var/lib/dhcpd/dhcpd.leases"
      @ec2_config_file    = "#{ENV['HOME']}/.jboss-cloud/ec2"
      @timeout            = 2
      @log                = Logger.new(STDOUT)

      @is_ec2             = is_port_open?( "169.254.169.254" )

      if @is_ec2
        validate_aws_config
        @ec2 = EC2::Base.new(:access_key_id => @aws_data['access_key'], :secret_access_key => @aws_data['secret_access_key'])
        # just for test if credentials are valid        
        @ec2.describe_availability_zones
      end
    end

    def allowed_ips
      local_ip = UDPSocket.open {|s| s.connect('64.233.187.99', 1); s.addr.last }

      [ '127.0.0.1', local_ip ]
    end

    def node_ips
      addresses         = []
      valid_addresses   = []

      unless @is_ec2
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
      else
        # if this is EC2
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

      end

      for ip in addresses
        @log.info "IP: #{ip}, checking if host is alive..."
        if Ping.pingecho( ip, @timeout )
          @log.info " \\__ ALIVE: Host #{ip} is alive, good"
          valid_addresses.push( ip )
        else
          @log.info " \\__ DEAD: Host #{ip} hadn't responded in #{@timeout} seconds, not so good, suspecting as dead, removing from cache"
        end
      end

      if valid_addresses.size > 0
        @log.info "Found #{valid_addresses.size} valid address#{valid_addresses.size > 1 ? "es" : ""}: #{valid_addresses.join(", ")}."
      else
        @log.info "No valid addresses found."
      end

      valid_addresses
    end

    # ========================================

    def validate_aws_config
      raise "Configuration file #{@ec2_config_file}, doesn't exists. Please create it."  unless File.exists?( @ec2_config_file )

      @aws_data = YAML.load_file( @ec2_config_file )

      raise "Invalid configuration file #{@ec2_config_file}, please check structure of this file." unless @aws_data
      raise "Please specify access key in aws section in configuration file #{@ec2_config_file}: access_key: YOUR_ACCESS_KEY" if @aws_data['access_key'].nil?
      raise "Please specify secret access key in aws section in configuration file #{@ec2_config_file}: secret_access_key: YOUR_SECRET_ACCESS_KEY" if @aws_data['secret_access_key'].nil?
    end

    def is_port_open?(ip, port = 80)
      begin
        Timeout::timeout(@timeout) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
      end

      return false
    end

  end
end
