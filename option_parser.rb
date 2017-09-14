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

require 'optparse'

class MainParser

  def self.parse(args)
    options = {}

    # Default options
    options['mirror'] = true
    options['meta'] = true
    
    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: repoman COMMAND [OPTIONS]"
      opt.separator  ""
      opt.separator  "Commands"
      opt.separator  "    generate: setup client repo config files"
      opt.separator  "    mirror: clone upstream repos"
      opt.separator  ""
      opt.separator  "Options"

      opt.on("-i","--include REPOLIST",Array,"which repositories should be used") do |repos|
        options["include"] = repos
      end

      opt.on("-d","--distro DISTRO","operating system to use") do |distro|
        options["distro"] = distro
      end

      opt.on("-o","--outfile OUTPUTFILE","repo config output file [GENERATE ONLY]") do |outfile|
        options["outfile"] = outfile
      end

      opt.on("-r","--reporoot PATH","mirror repository root path [MIRROR ONLY]") do |reporoot|
        options["reporoot"] = reporoot
      end

      opt.on("--configurlsearch URL-TO-FIND","the url string to be replaced by `configurlreplace` in `configfile` [MIRROR ONLY]") do |urlsearch|
        options["configurlsearch"] = urlsearch
      end

      opt.on("--configurlreplace URL-TO-REPLACE","the url string to replace `configurlsearch` in `configfile` [MIRROR ONLY]") do |urlreplace|
        options["configurlreplace"] = urlreplace
      end

      opt.on("--configfile","the file to perform url replacement on [MIRROR ONLY]") do |configfile|
        options["configfile"] = configfile
      end

      opt.on("-h","--help","help") do
        puts opt
        exit
      end

      opt.on("--no-mirror","do not update repository packages [MIRROR ONLY]") do |mirror|
        options['mirror'] = mirror
      end

      opt.on("--no-meta","do not update repository metadata [MIRROR ONLY]") do |meta|
        options['meta'] = meta
      end
    end
    # Remove options from ARGV and store within opt_parser object
    opt_parser.parse!(args)
    
    # Return options
    return options
  end

end
