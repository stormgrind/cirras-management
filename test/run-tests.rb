require 'test/unit'

$: << File.dirname("#{File.dirname( __FILE__ )}/../lib/jboss-cloud-management")
Dir.chdir( File.dirname( __FILE__ ) )

require 'jboss-cloud-management/api/2009-05-18/handler/put/management-address-request-handler-test'