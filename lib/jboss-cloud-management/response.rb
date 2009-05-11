module JBossCloudManagement
  class Response
    def initialize( appliance_names )
      @appliance_names = appliance_names
    end

      attr_reader :appliance_name
  end
end