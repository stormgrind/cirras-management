$: << 'lib'

require 'jboss-cloud-management/manager'
require 'jboss-cloud-management/helper/log-helper'

module JBossCloudManagement
    Manager.new
    use Rack::CommonLogger, LogHelper.instance.web_log    
end

run Sinatra::Application