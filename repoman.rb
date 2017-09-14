#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Repoman.
#
# Alces Repoman is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Repoman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Repoman, please visit:
# https://github.com/alces-software/repoman
#==============================================================================

$LOAD_PATH << File.dirname(__FILE__)

# Requirements
require 'option_parser'
require 'commands'

# Parse arguments
options = MainParser.parse(ARGV)

# Decide on function to run
case ARGV[0]
when "generate"
  Commands::Generate.run(options)
when "mirror"
  Commands::Mirror.run(options)
else
  options = MainParser.parse(['--help']) 
end

=begin
# Write out file
if options['save']
  repoconfig.write_to_config
else
  puts 'not_saving'
end
=end
