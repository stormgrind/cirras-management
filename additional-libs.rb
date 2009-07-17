additional_libs = [ "sinatra", "amazon-ec2", "rest-client" ]

# "thin", "rack", "eventmachine"

additional_libs.each do |lib|
 $LOAD_PATH.unshift( "#{File.dirname( __FILE__ )}/lib/#{lib}/lib" )
end

