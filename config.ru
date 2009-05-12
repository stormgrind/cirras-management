require 'rubygems'
require 'restclient'

$: << 'lib'

require 'jboss-cloud-management/manager'
require 'jboss-cloud-management/helper/log-helper'

module JBossCloudManagement
    Manager.new
    use Rack::CommonLogger, LogHelper.instance.web_log
    RestClient.log = LogHelper.instance.client_log_file
end

run Sinatra::Application