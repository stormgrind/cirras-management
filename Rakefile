RUBY_1_9 = RUBY_VERSION =~ /^1\.9/
WIN      = (RUBY_PLATFORM =~ /mswin|cygwin/)
SUDO     = (WIN ? "" : "sudo")

require 'rake'
require 'rake/clean'
require 'additional-libs'

Dir.chdir( "lib/thin" )

load 'tasks/ext.rake'

ext_task :thin_parser

task :default => :compile