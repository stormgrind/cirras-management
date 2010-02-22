require 'cirras-management/api/2009-05-18/handler/put/management-address-request-handler'
require 'cirras-management/model/handler-to'
require 'cirras-management/model/config'

module CirrASManagement
  describe ManagementAddressRequestHandler do

    it "should execute commands for front-end appliance" do
      prepare_handler( "front-end" )

      RHQAgentUpdateCommand.should_receive(:new).with({
              :appliance_name => "front-end",
              :management_appliance_address => "10.1.0.1"
      }).once

      @handler.management_address_request("10.1.0.1")
    end

    it "should NOT execute commands for front-end appliance because same management address is received" do
      prepare_handler( "front-end" )

      @handler.instance_variable_set(:@management_address, "10.1.0.1")
      RHQAgentUpdateCommand.should_not_receive(:new)
      @handler.management_address_request("10.1.0.1")
    end

    it "should execute commands for back-end appliance" do
      prepare_handler( "back-end" )

      @handler.instance_variable_set(:@back_end_cmds_running, false)

      JBossCommandFactory.should_receive(:new).with(:log => @log, :mgmt_address => "10.1.0.1", :environment => :default)
      RHQAgentUpdateCommand.should_receive(:new).with(:appliance_name => "back-end", :management_appliance_address => "10.1.0.1")

      @handler.management_address_request("10.1.0.1")
    end


    def prepare_handler( appliance_name )
      @log = Logger.new('/dev/null')

      config_helper = ConfigHelper.new(
              :rack_config_file => "src/config.yml",
              :boxgrinder_config_file => "src/etc/boxgrinder-#{appliance_name}-appliance",
              :log => @log )

      config_helper.stub!(:is_ec2?).and_return(false)

      to = HandlerTO.new( "api", "latest", config_helper.config, @log)

      @handler = ManagementAddressRequestHandler.new("/a/path", to )
    end

  end
end