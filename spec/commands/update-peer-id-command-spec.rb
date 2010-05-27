require 'cirras-management/api/commands/update-peer-id-command'

module CirrASManagement

  describe UpdatePeerIdCommand do

    before(:all) do
      @jboss_home = "/opt/jboss-as6"
    end

    before(:each) do
      Socket.should_receive(:gethostname).any_number_of_times.and_return("localhost")

      @cmd            = UpdatePeerIdCommand.new( :mgmt_address => "10.1.0.1", :log => Logger.new('/dev/null') )
      @exec_helper    = @cmd.instance_variable_get(:@exec_helper)
      @client_helper  = @cmd.instance_variable_get(:@client_helper)
    end

    it "should not break if there is nil injected as management address" do
      UpdatePeerIdCommand.new( :log => Logger.new('/dev/null') ).execute
    end

    it "should not break if completely invalid PeerID is received" do
      @cmd.should_receive(:load_peer_id).once.and_return(true)

      inject_peer_id_1

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin get jboss.messaging:service=ServerPeer ServerPeerID" ).once.and_return("xyz")
      @exec_helper.should_not_receive(:execute)
      @cmd.execute
    end

    it "should not break if invalid PeerID is received" do
      @cmd.should_receive(:load_peer_id).once.and_return(true)

      inject_peer_id_1

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin get jboss.messaging:service=ServerPeer ServerPeerID" ).once.and_return("ServerPeerID=xyz")
      @exec_helper.should_not_receive(:execute)
      @cmd.execute
    end

    it "should not update peer id because it's same as previous" do
      @cmd.should_receive(:load_peer_id).once.and_return(true)

      @cmd.instance_variable_set(:@peer_id, "1")

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin get jboss.messaging:service=ServerPeer ServerPeerID" ).once.and_return("ServerPeerID=1")
      @exec_helper.should_not_receive(:execute)

      @cmd.execute
    end

    it "should update peer id" do
      @cmd.should_receive(:load_peer_id).once.and_return(true)

      inject_peer_id_1

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin get jboss.messaging:service=ServerPeer ServerPeerID" ).once.and_return("ServerPeerID=2")
      @exec_helper.should_not_receive(:execute)
      @cmd.execute
    end

    it "should not update when received peer id is not valid" do
      @cmd.should_receive(:load_peer_id).once.and_return(false)

      @exec_helper.should_not_receive(:execute)
      @cmd.execute
    end

    it "should load peer id" do
      @client_helper.should_receive(:get).with( "http://10.1.0.1:4545/latest/peer-id" ).and_return( "2" )
      @cmd.load_peer_id.should == true
    end

    it "should not load peer id" do
      @client_helper.should_receive(:get).with( "http://10.1.0.1:4545/latest/peer-id" ).and_return( "2xcsf" )
      @cmd.load_peer_id.should == false
    end

    def inject_peer_id_1
      @cmd.instance_variable_set(:@peer_id, "1")

      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin invoke jboss.messaging:service=ServerPeer stop" ).once
      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin set jboss.messaging:service=ServerPeer ServerPeerID 1" ).once
      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost -u admin -p admin invoke jboss.messaging:service=ServerPeer start" ).once
    end
  end
end

