require 'cirras-management/helper/exec-helper'
require 'cirras-management/helper/client-helper'
require 'cirras-management/helper/ip-helper'
require 'cirras-management/defaults'

module CirrASManagement
  class BaseJBossASCommand
    def initialize( options = {} )
      @log            = options[:log]           || LOG
      @exec_helper    = options[:exec_helper]   || ExecHelper.new( { :log => @log } )
      @client_helper  = options[:client_helper] || ClientHelper.new( { :log => @log } )
      @ip_helper      = options[:ip_helper]     || IPHelper.new( { :log => @log } )
    end

    def twiddle_execute( command )
      @log.debug "Executing '#{command}' using Twiddle..."
      out = @exec_helper.execute("#{JBOSS_HOME}/bin/twiddle.sh -s #{Socket.gethostname} #{command}")
      @log.debug "Command executed."
      out
    end
  end
end