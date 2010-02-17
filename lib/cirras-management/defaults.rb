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

require 'cirras-management/helper/log-helper'

module CirrASManagement
  APPLIANCE_TYPE = {
          :backend        => "back-end",
          :frontend       => "front-end",
          :management     => "management",
          :postgis        => "postgis"
  }

  APIS = [ "2009-05-18" ]

  DEFAULT_FRONT_END_PORT  = 80
  MANAGEMENT_PORT         = 4545
  JBOSS_HOME              = "/opt/jboss-as6"
  JBOSS_SERVICE_NAME      = "jboss-as6"
  JBOSS_SYSCONFIG_FILE    = "/etc/sysconfig/jboss-as6"
  BOXGRINDER_CONFIG_FILE  = "/etc/boxgrinder"
  RACK_CONFIG_FILE        = "config/config.yaml"
  LEASES_FILE             = "/var/lib/dhcpd/dhcpd.leases"
  RHQ_AGENT_SYSCONF_FILE  = "/etc/sysconfig/rhq-agent"

  LOG_DEFAULT_FILE        = "/var/log/cirras-management/default.log"
  LOG_WEB_FILE            = "/var/log/cirras-management/web.log"
  LOG_CLIENT_FILE         = "/var/log/cirras-management/client.log"
end