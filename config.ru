require 'rubygems'
require 'restclient'

$: << 'lib'

require 'cirras-management/manager'
require 'cirras-management/helper/log-helper'

module CirrASManagement
    Manager.new
    use Rack::CommonLogger
    RestClient.log = LogHelper.instance.client_log_file
end

run Sinatra::Application