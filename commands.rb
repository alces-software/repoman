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

module Commands
  
  class Base
    
    def self.run(args)
      @required_base = ['distro','include']
      @args = args
      puts "running command with: #{@args}"
      self.check_required
      self.main
    end

    def self._required_other
      @required_other = []
    end

    def self.check_required
      #puts "checking for required options"
      self._required_other
      missing = []
      required = @required_base + @required_other
      required.each do |key|
        if ! @args.key?(key)
           missing << "--#{key}"
        end
      end

      if missing.any?
        puts "missing arg(s): #{missing.join(", ")}"
        exit 1
      end

    end

    def self.main
      puts "oops, `self.main` hasn't been overridden in child class!"
      exit 1
    end

    def self._get_source_path(file)
      # Split distro at integer and join back together with /
      return "templates/#{@args['distro'].split(/(\d+)/).join('/')}/#{file}"
    end

  end

  class Generate < Base
    def self._required_other
      @required_other = ['outfile']
    end

    def self.main
      sourcefiles = []
      @args['include'].each do |repo|
        sourcefiles << self._get_source_path(repo)
      end
      %x(cat #{sourcefiles.join(' ')} > #{@args['outfile']})
    end

  end

  class Mirror < Base
    def self._required_other
      @required_other = ['mirrordest', 'configurlsearch', 'configurlreplace', 'configfile']
    end
  end

end
