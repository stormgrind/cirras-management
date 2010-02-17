require 'cirras-management/api/commands/update-s3ping-credentials-command'

module CirrASManagement
  describe UpdateS3PingCredentialsCommand do

    before(:each) do
      @cmd = UpdateS3PingCredentialsCommand.new
    end

    it "should update credentials" do
      jboss_config_with_credentials = File.read("#{File.dirname(__FILE__)}/../src/etc/sysconfig/jboss-as6-credentials")

      File.should_receive(:open).once

      @cmd.instance_variable_set(:@jboss_config, jboss_config_with_credentials)
      @cmd.instance_variable_set(:@aws_credentials, { 'access_key' => 'a', 'secret_access_key' => 'b', 'bucket' => 'c'})

      @cmd.write_credentials

      jboss_config = @cmd.instance_variable_get(:@jboss_config)

      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_ACCESS_KEY=(.*)$/).to_s.should eql("a")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_SECRET_ACCESS_KEY=(.*)$/).to_s.should eql("b")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_BUCKET=(.*)$/).to_s.should eql("c")
    end

    it "should return true because there is an empty line on the end" do
      @cmd.is_last_line_empty?("asd\nasd\nasdasd\n").should == true
    end

    it "should return false because there is an empty line on the end but with whitespaces" do
      @cmd.is_last_line_empty?("asd\nasd\nasdasd\n   ").should == false
    end

    it "should return false because there is no empty line on the end" do
      @cmd.is_last_line_empty?("asd\nasd\nasdasd").should == false
    end

    it "should add credentials" do
      jboss_config_empty = File.read("#{File.dirname(__FILE__)}/../src/etc/sysconfig/jboss-as6-empty")

      File.should_receive(:open).once

      @cmd.instance_variable_set(:@jboss_config, jboss_config_empty)
      @cmd.instance_variable_set(:@aws_credentials, { 'access_key' => 'a', 'secret_access_key' => 'b', 'bucket' => 'c'})
      @cmd.write_credentials

      jboss_config = @cmd.instance_variable_get(:@jboss_config)

      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_ACCESS_KEY=(.*)$/).to_s.should eql("a")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_SECRET_ACCESS_KEY=(.*)$/).to_s.should eql("b")
      jboss_config.scan(/^JBOSS_JGROUPS_S3_PING_BUCKET=(.*)$/).to_s.should eql("c")
    end

    it "should read credentials" do
      jboss_config_mixed = File.read("#{File.dirname(__FILE__)}/../src/etc/sysconfig/jboss-as6-mixed")

      @cmd.instance_variable_set(:@jboss_config, jboss_config_mixed)
      credentials = @cmd.read_credentials

      credentials['access_key'].should eql("accesskey")
      credentials['secret_access_key'].should eql("secretaccesskey")
      credentials['bucket'].should eql("")
    end

  end
end

