RSPEC_BASE_LOCATION = File.dirname(__FILE__)

# commands
require 'commands/update-proxy-list-command-spec'
require 'commands/update-peer-id-command-spec'
require 'commands/update-rhq-agent-command-spec'
require 'commands/update-s3ping-credentials-command-spec'


# handlers
require 'handlers/management-address-request-handler-spec'

# helpers
require 'helpers/string-helper-spec'
require 'helpers/config-helper-spec'