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

require 'cirras-management/api/2009-05-18/handler/helper/base-request-handler-helper'
require 'cirras-management/api/2009-05-18/handler/get/address-request-handler'
require 'cirras-management/api/2009-05-18/handler/get/aws-credentials-request-handler'

module CirrASManagement
  class ManagementApplianceRequestHandlerHelper < BaseRequestHandlerHelper
    def initialize( to )
      super( to )

      register_handler( :address_request, AddressRequestHandler.new( "/#{@prefix}/address/:appliance", @to ) )
      register_handler( :aws_credentials_request, AWSCredentialsRequestHandler.new( "/#{@prefix}/awscredentials", @to ) )
    end
  end
end
