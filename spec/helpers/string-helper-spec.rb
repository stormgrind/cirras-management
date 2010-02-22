require 'cirras-management/helper/string-helper'

module CirrASManagement
  describe StringHelper do

    before(:each) do
      @helper = StringHelper.new
    end

    it "should return true because there is an empty line on the end" do
      @helper.is_last_line_empty?("asd\nasd\nasdasd\n").should == true
    end

    it "should return false because there is an empty line on the end but with whitespaces" do
      @helper.is_last_line_empty?("asd\nasd\nasdasd\n   ").should == false
    end

    it "should return false because there is no empty line on the end" do
      @helper.is_last_line_empty?("asd\nasd\nasdasd").should == false
    end

  end
end

