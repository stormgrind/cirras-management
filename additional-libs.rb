additional_libs = [ "eventmachine", "sinatra", "amazon-ec2", "thin", "rack", "rest-client" ]

additional_libs.each do |lib|
 $LOAD_PATH.unshift( "#{File.dirname( __FILE__ )}/lib/#{lib}/lib" )
end

