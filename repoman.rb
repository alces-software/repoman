#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)

# Requirements
require 'optparse'
#require 'commands'
require 'config_file'

# Load config file
repoconfig = ConfigFile::ConfigBase.new('.repoman')

# Option Parser Object Setup
options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: repoman COMMAND [OPTIONS]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "    client: setup client repo config files"
  opt.separator  "    server: mirror upstream repos"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-s","--source SOURCE","which upstream repository should be used") do |source|
    options[:source] = source
  end

  opt.on("-d","--distro","operating system to use") do |distro|
    options[:distro] = distro
  end

  opt.on("-r","--release","operating system version to use") do |version|
    options[:version] = version
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

# Remove options from ARGV and store within opt_parser object
opt_parser.parse!

# Update configuration options
puts options.inspect
puts repoconfig.inspect



=begin
# Decide on function to run
case ARGV[0]
when "client"
  puts "running client command with: #{options.inspect}"
when "server"
  puts "running server command with: #{options.inspect}"
else
  puts opt_parser
end
=end
