module JBossCloudManagement
  class Node
    def initialize( name )
      @name = name
    end

    attr_accessor :address
    attr_accessor :name

  end
end
