require 'cirras-management/api/commands/update-jvm-route-command'

module CirrASManagement

  describe UpdateJVMRouteCommand do

    before(:all) do
      @jboss_home = "/opt/jboss-as6"
    end

    before(:each) do
      Socket.should_receive(:gethostname).any_number_of_times.and_return("localhost")

      @cmd            = UpdateJVMRouteCommand.new( { :log => Logger.new('/dev/null') } )
      @exec_helper    = @cmd.instance_variable_get(:@exec_helper)
      @client_helper  = @cmd.instance_variable_get(:@client_helper)
      @ip_helper      = @cmd.instance_variable_get(:@ip_helper)
    end

    it "should calculate jvm route" do
      @ip_helper.should_receive(:local_ip).and_return("10.1.0.1")

      @cmd.calculate_jvm_route.should ==true
      @cmd.instance_variable_get(:@jvm_route).should eql("localhost-10.1.0.1")
    end

    it "should update jvm route" do
      @ip_helper.should_receive(:local_ip).and_return("10.1.0.1")

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost get jboss.web:type=Engine jvmRoute" ).once.and_return("jvmRoute=12")
      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost set jboss.web:type=Engine jvmRoute localhost-10.1.0.1" )
      @exec_helper.should_not_receive(:execute)

      @cmd.execute
    end

    it "should not update jvm route" do
      @ip_helper.should_receive(:local_ip).and_return("10.1.0.1")

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost get jboss.web:type=Engine jvmRoute" ).once.and_return("jvmRoute=localhost-10.1.0.1")
      @exec_helper.should_not_receive(:execute)

      @cmd.execute
    end

  end
end

