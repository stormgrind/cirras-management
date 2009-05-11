require 'rubygems'
require 'sinatra'
require 'fastthread'

$: << 'lib/jboss-cloud-management-support'

require 'lib/jboss-cloud-management/manage'

manage = JBossCloudManagement::Manage.new

t = Thread.new do
  while true do
    
    manage.valid_nodes
    sleep 30
  end
end

get '/info' do
  "manage.valid_nodes"
end
