module JBossCloudManagement
  class Node
    def initialize( name, address )
      @address  = address
      @name     = name
    end

    attr_accessor :address
    attr_accessor :name

  end
end
