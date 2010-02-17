require 'cirras-management/api/commands/update-proxy-list-command'

module CirrASManagement

  describe UpdateProxyListCommand do

    before(:all) do
      @jboss_home = "/opt/jboss-as6"
    end

    before(:each) do
      Socket.should_receive(:gethostname).any_number_of_times.and_return("localhost")
      @cmd          = UpdateProxyListCommand.new( :mgmt_address => "10.1.0.1", :log => Logger.new('/dev/null') )
      @exec_helper  = @cmd.instance_variable_get(:@exec_helper)
    end

    it "should not break if there is nil injected as management address" do
      UpdateProxyListCommand.new( :log => Logger.new('/dev/null') ).execute
    end

    it "should add one proxy" do
      @cmd.instance_variable_set(:@proxies, [ "10.1.0.1" ])
      @cmd.stub!(:load_front_end_list).and_return(true)
      @cmd.stub!(:get_current_proxies).and_return({})

      @cmd.should_receive(:add_proxy).once.with( "10.1.0.1", 80 )
      @cmd.should_not_receive(:remove_proxy)

      @cmd.execute
    end

    it "should update one proxy" do
      @cmd.instance_variable_set(:@proxies, [ "10.1.0.1" ])
      @cmd.stub!(:load_front_end_list).and_return(true)
      @cmd.stub!(:get_current_proxies).and_return({ "10.1.0.1" => { :host => "10.1.0.1", :port => 1234 } })

      @cmd.should_receive(:remove_proxy).once.with( "10.1.0.1", 1234 )
      @cmd.should_receive(:add_proxy).once.with( "10.1.0.1", 80 )

      @cmd.execute
    end

    it "should remove one proxy" do
      @cmd.instance_variable_set(:@proxies, [])
      @cmd.stub!(:load_front_end_list).and_return(true)
      @cmd.stub!(:get_current_proxies).and_return({ "10.1.0.1" => { :host => "10.1.0.1", :port => 1234 } })

      @cmd.should_receive(:remove_proxy).once.with( "10.1.0.1", 1234 )
      @cmd.should_not_receive(:add_proxy)
      @cmd.execute
    end

    it "should update proxy port" do
      @cmd.instance_variable_set(:@proxies, [ "10.1.0.2" ])
      @cmd.stub!(:load_front_end_list).and_return(true)
      @cmd.stub!(:get_current_proxies).and_return({ "10.1.0.2" => { :host => "10.1.0.2", :port => 1234 } })

      @cmd.should_receive(:remove_proxy).once.with( "10.1.0.2", 1234 )
      @cmd.should_receive(:add_proxy).once.with( "10.1.0.2", 80 )
      @cmd.execute
    end

    it "should make a big update on proxy list" do
      @cmd.stub!(:load_front_end_list).and_return(true)
      @cmd.instance_variable_set(:@proxies, [ "10.1.0.2", "10.1.0.3", "10.1.0.4", "10.1.0.5" ])

      @cmd.stub!(:get_current_proxies).and_return( {
              "10.1.0.4" => { :host => "10.1.0.4", :port => 1234 },
              "10.1.0.5" => { :host => "10.1.0.5", :port => 80 }
      })

      @cmd.should_receive(:remove_proxy).once.with( "10.1.0.4", 1234 )
      @cmd.should_receive(:add_proxy).once.with( "10.1.0.4", 80 )
      @cmd.should_receive(:add_proxy).once.with( "10.1.0.2", 80 )
      @cmd.should_receive(:add_proxy).once.with( "10.1.0.3", 80 )

      @cmd.execute
    end

    it "should load 2 proxies" do
      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost get jboss.web:service=ModCluster ProxyInfo" ).once.and_return("ProxyInfo={/10.210.30.227:80=Node: [1],Name: localhost.localdomain-10.211.94.34,Balancer: mycluster,Domain: ,Host: 10.211.94.34,Port: 8009,Type: ajp,Flushpackets: Off,Flushwait: 10000,Ping: 10000000,Smax: 1,Ttl: 60000000,Elected: 0,Read: 0,Transfered: 0,Connected: 0,Load: 93 Node: [2],Name: localhost.localdomain-10.210.59.133,Balancer: mycluster,Domain: ,Host: 10.210.59.133,Port: 8009,Type: ajp,Flushpackets: Off,Flushwait: 10000,Ping: 10000000,Smax: 1,Ttl: 60000000,Elected: 0,Read: 0,Transfered: 0,Connected: 0,Load: 97 , /10.210.85.220:80=Node: [1],Name: localhost.localdomain-10.211.94.34,Balancer: mycluster,Domain: ,Host: 10.211.94.34,Port: 8009,Type: ajp,Flushpackets: Off,Flushwait: 10000,Ping: 10000000,Smax: 1,Ttl: 60000000,Elected: 0,Read: 0,Transfered: 0,Connected: 0,Load: 93 Node: [2],Name: localhost.localdomain-10.210.59.133,Balancer: mycluster,Domain: ,Host: 10.210.59.133,Port: 8009,Type: ajp,Flushpackets: Off,Flushwait: 10000,Ping: 10000000,Smax: 1,Ttl: 60000000,Elected: 0,Read: 0,Transfered: 0,Connected: 0,Load: 97}")
      @cmd.get_current_proxies.size.should == 2
    end

    it "should load 1 proxy" do
      @exec_helper.should_receive(:execute).with( "#{@jboss_home}/bin/twiddle.sh -s localhost get jboss.web:service=ModCluster ProxyInfo" ).once.and_return("ProxyInfo={/10.210.30.227:80=Node: [1],Name: localhost.localdomain-10.211.94.34,Balancer: mycluster,Domain: ,Host: 10.211.94.34,Port: 8009,Type: }")
      @cmd.get_current_proxies.size.should == 1
    end
  end
end

