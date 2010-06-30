require 'cirras-management/helper/config-helper'
require 'rspec-helpers/rspec-config-helper'

module CirrASManagement
  include RSpecConfigHelper

  describe ConfigHelper do

    before(:each) do
    end

    it "should get appliance name from boxgrinder file" do
      helper = ConfigHelper.new( :boxgrinder_config_file => "#{RSpecConfigHelper::RSPEC_BASE_LOCATION}/src/etc/sysconfig/boxgrinder" )
      helper.get_appliance_name.should == "testappliance"
    end

  end
end

