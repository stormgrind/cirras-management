$: << 'lib/jboss-cloud-management'

require 'server'

module JBossCloudManagement
    Server.new
end

run Sinatra::Application