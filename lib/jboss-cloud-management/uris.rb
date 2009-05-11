require 'rubygems'
require 'sinatra'

module JBossCloudManagement
  class URIs
    def initialize

      preparet_get
    end

    def preparet_get
      get '/*' do
        "it works"
      end
    end
  end
end

