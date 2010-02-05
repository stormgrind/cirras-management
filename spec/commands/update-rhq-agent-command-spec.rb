require 'cirras-management/api/commands/update-rhq-agent-command'

module CirrASManagement
  describe RHQAgentUpdateCommand do

    before(:all) do
      @log = Logger.new('/dev/null')
    end

    before(:each) do
      Socket.should_receive(:gethostname).any_number_of_times.and_return("a-fancy-hostname")

      @exec_helper    = @cmd.instance_variable_get(:@exec_helper)
      @ip_helper      = @cmd.instance_variable_get(:@ip_helper)
    end

    def prepare_cmd( appliance_name, configuration_file )
      @cmd = RHQAgentUpdateCommand.new( appliance_name, configuration_file, { :log => Logger.new(STDOUT) } )
    end

    it "should not fail when invalid agent configuration file is injected" do
      prepare_cmd( "back-end", "doesntexists/agent-congiguration.xml" )
      @cmd.execute
    end

    it "should update entry" do
      prepare_cmd( "back-end", "doesntexists/agent-congiguration.xml" )

      @cmd.should_receive(:load_configuration).once.ordered.and_return(true)
      @cmd.should_receive(:update_entry).once.ordered.with("rhq.agent.name", "back-end-a-fancy-hostname")
      @cmd.should_receive(:update_file).once.ordered

      @cmd.execute
    end

    it "should update entry with no appliance name specified" do
      prepare_cmd( nil, "doesntexists/agent-congiguration.xml" )

      @cmd.should_receive(:load_configuration).once.ordered.and_return(true)
      @cmd.should_receive(:update_entry).once.ordered.with("rhq.agent.name", "a-fancy-hostname")
      @cmd.should_receive(:update_file).once.ordered

      @cmd.execute
    end

    it "should not update entry" do
      prepare_cmd( "back-end", "doesntexists/agent-congiguration.xml" )

      @cmd.should_receive(:load_configuration).once.and_return(false)
      @cmd.should_not_receive(:update_entry)
      @cmd.should_not_receive(:update_file)

      @cmd.execute
    end

    it "should load configuration" do
      prepare_cmd( "appliance", "src/default-agent-configuration.xml" )

      doc = Nokogiri::XML::Document.new
      @cmd.should_receive(:get_entries_by_key).with("rhq.agent.configuration-schema-version").once.and_return(Nokogiri::XML::NodeSet.new( doc, [ Nokogiri::XML::Node.new( "entry", doc ) ]))
      @cmd.load_configuration.should == true
    end

    it "should update one entry with values" do
      prepare_cmd( "appliance", "src/default-agent-configuration.xml" )

      doc = Nokogiri::XML::Document.new

      @cmd.instance_variable_set(:@agent_configuration, doc)

      root_node = Nokogiri::XML::Node.new( "root", doc )
      doc.add_child( root_node )

      @cmd.instance_variable_set(:@entry_map, root_node )
      @cmd.update_entry( "key", "value" )

      @cmd.instance_variable_get(:@agent_configuration).xpath("//entry[@key='key']").size.should == 1
    end
  end
end

