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

require 'fileutils'

#$repomanroot = '/opt/repoman'
$repomanroot = '/Users/stu/RUBY/repoman'

module Commands
  
  class Base
    
    def self.run(args)
      @required_base = ['distro','include']
      @args = args
      #puts "running command with: #{@args}"
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

    def self._get_source_file_path(file)
      # Split distro at integer and join back together with /
      return "#{$repomanroot}/templates/#{@args['distro'].split(/(\d+)/).join('/')}/#{file}"
    end

  end

  class Generate < Base
    def self._required_other
      @required_other = ['outfile']
    end

    def self.main
      sourcefiles = []
      @args['include'].each do |repo|
        sourcefiles << self._get_source_file_path(repo)
      end
      %x(cat #{sourcefiles.join(' ')} > #{@args['outfile']})
      puts "The file(s) #{sourcefiles.join(' ')} have been saved to #{@args['outfile']}"
    end

  end

  class Mirror < Base
    def self._required_other
      #@required_other = ['reporoot', 'configurlsearch', 'configurlreplace', 'configfile']
      @required_other = ['reporoot']
    end

    def self.main
      @repoconf = @args['reporoot'] + '/mirror.conf'
      self.setup_repo
      @args['include'].each do |file|
        # Loop through each repository defined in file
        File.read(self._get_source_file_path(file)).scan(/(?<=name=).*/).each do |repo|
          self.sync_repo(repo)
          self.generate_metadata(repo)
        end
      end
    end

    def self.setup_repo
      # Create reporoot if it doesn't exist
      if ! File.directory?(@args['reporoot'])
        FileUtils::mkdir_p @args['reporoot']
      end

      # Create top of mirror.conf file with general config
      File.write(@repoconf, '
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=5
reposdir=/dev/null

')

      # Add all additional repo data to file
      @args['include'].each do |file|
        File.write(@repoconf, %x(cat #{self._get_source_file_path(file)}), File.size(@repoconf), mode: 'a')
      end
    end

    def self.sync_repo(repo)
      if @args['mirror']
        %x(reposync -nm --config #{@repoconf} -r #{repo} -p #{self._get_repo_path(repo)} --norepopath)
      end
    end

    def self.generate_metadata(repo)
      if @args['meta']
        %x(createrepo #{self._get_repo_path(repo)})
      end
    end

    def self._get_repo_path(file)
      # Split distro at integer and join back together with /
      return "#{@args['reporoot']}/#{file.split(/-/).join('/')}/"
    end
  end

end
