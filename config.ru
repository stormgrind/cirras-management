$: << 'lib'

require 'jboss-cloud-management/manager'

module JBossCloudManagement
    Manager.new
end

run Sinatra::Application