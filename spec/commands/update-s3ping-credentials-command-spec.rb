require 'cirras-management/api/commands/update-s3ping-credentials-command'

module CirrASManagement
  describe UpdateS3PingCredentialsCommand do

    it "should update credentials" do
      cmd = UpdateS3PingCredentialsCommand.new(nil)

      jboss_config_with_credentials = File.read("#{File.dirname(__FILE__)}/../src/etc/sysconfig/jboss-as6-credentials")

      File.should_receive(:read).with("/etc/sysconfig/jboss-as6").once.and_return(jboss_config_with_credentials)
      File.should_receive(:open).once

      cmd.write_credentials("a", "b", "c")

      jboss_config = cmd.instance_variable_get(:@jboss_config)

      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_ACCESS_KEY=(.*)$/).to_s.should eql("a")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_SECRET_ACCESS_KEY=(.*)$/).to_s.should eql("b")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_BUCKET_LOCATION=(.*)$/).to_s.should eql("c")
    end

    it "should return true because there is an empty line on the end" do
      UpdateS3PingCredentialsCommand.new(nil).is_last_line_empty?("asd\nasd\nasdasd\n").should == true
    end

    it "should return false because there is an empty line on the end but with whitespaces" do
      UpdateS3PingCredentialsCommand.new(nil).is_last_line_empty?("asd\nasd\nasdasd\n   ").should == false
    end

    it "should return false because there is no empty line on the end" do
      UpdateS3PingCredentialsCommand.new(nil).is_last_line_empty?("asd\nasd\nasdasd").should == false
    end

    it "should add credentials" do
      cmd = UpdateS3PingCredentialsCommand.new(nil)

      jboss_config_empty = File.read("#{File.dirname(__FILE__)}/../src/etc/sysconfig/jboss-as6-empty")

      File.should_receive(:read).with("/etc/sysconfig/jboss-as6").once.and_return(jboss_config_empty)
      File.should_receive(:open).once

      cmd.write_credentials("a", "b", "c")

      jboss_config = cmd.instance_variable_get(:@jboss_config)

      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_ACCESS_KEY=(.*)$/).to_s.should eql("a")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_SECRET_ACCESS_KEY=(.*)$/).to_s.should eql("b")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_BUCKET_LOCATION=(.*)$/).to_s.should eql("c")
    end
  end
end

