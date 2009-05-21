require 'jboss-cloud-management/helper/client-helper'

module JBossCloudManagement
  class ClientHelperMock < ClientHelper

    def get( url, address )
      address
    end

    def put( url, address, data )
      data
    end
  end
end
