require 'rubygems'
require 'rest_client'
require 'yaml'

puts RestClient.get('http://10.1.0.5:4545/info').to_yaml
