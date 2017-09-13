#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)

# Requirements
require 'option_parser'
#require 'commands'
require 'config_file'

# Load config file
repoconfig = ConfigFile::ConfigBase.new('.repoman')

# Parse arguments
options = MainParser.parse(ARGV)

# Update configuration options
repoconfig.merge(options)

# Decide on function to run
case ARGV[0]
when "client"
  puts "running client command with: #{repoconfig.inspect}"
when "server"
  puts "running server command with: #{repoconfig.inspect}"
else
  options = MainParser.parse(['--help']) 
end

# Write out file
if options['save']
  repoconfig.write_to_config
else
  puts 'not_saving'
end
