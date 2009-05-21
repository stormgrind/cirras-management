require 'jboss-cloud-management/api/2009-05-18/handler/put/management-address-request-handler'
require 'jboss-cloud-management/api/2009-05-18/handler/handler-to'
require 'jboss-cloud-management/config'
require 'jboss-cloud-management/manager'
require 'jboss-cloud-management/mock/client-helper-mock'

class ManagementAddressRequestHandlerTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    log = Logger.new(STDOUT)

    config = JBossCloudManagement::Config.new( log )
    config.appliance_name = JBossCloudManagement::APPLIANCE_TYPE[:backend]

    to = JBossCloudManagement::HandlerTO.new( "latest", "2009-08-12", config , log )
    @management_address_request_handler = JBossCloudManagement::ManagementAddressRequestHandler.new( '/path', to )

    @management_address_request_handler.client_helper = JBossCloudManagement::ClientHelperMock.new( config, log )
    @management_address_request_handler.jboss_as5_conf_file = "src/jboss-as5.conf"
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_fail
    @management_address_request_handler.management_address_request( "127.0.0.1" )
  end
end