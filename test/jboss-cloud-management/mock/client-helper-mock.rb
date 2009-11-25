require 'jboss-cloud-management/helper/client-helper'

module CirrASManagement
  class ClientHelperMock < ClientHelper

    def get( url, address )
      address
    end

    def put( url, address, data )
      data
    end
  end
end
