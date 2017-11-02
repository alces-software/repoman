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
    options['conf'] = true
    
    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: repoman COMMAND [OPTIONS]"
      opt.separator  ""
      opt.separator  "Commands"
      opt.separator  "    show: show available repo config files"
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

      opt.on("--configurl REPO-URL","the url for the local repository [MIRROR ONLY]") do |configurl|
        options["configurl"] = configurl
      end

      opt.on("--configout OUTPUTFILE","the file to output repository files for clients to use", "(this is optional, if not specified then the file will", "be written to `/var/lib/repoman/templates/DISTRO/VERSION/local.repo` [MIRROR ONLY]") do |configout|
        options["configout"] = configout
      end

      opt.on("-h","--help","show this help screen") do
        puts opt
        exit
      end

      opt.on("--no-mirror","do not update repository packages [MIRROR ONLY]") do |mirror|
        options['mirror'] = mirror
      end

      opt.on("--no-meta","do not update repository metadata [MIRROR ONLY]") do |meta|
        options['meta'] = meta
      end

      opt.on("--no-conf","do not setup repository but update existing repos [MIRROR ONLY]") do |conf|
        options['conf'] = conf
      end

    end
    # Remove options from ARGV and store within opt_parser object
    opt_parser.parse!(args)
    
    # Return options
    return options
  end

end
