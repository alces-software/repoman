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

$repomanroot = '/opt/repoman'

module Commands
  
  class Base
    
    def self.run(args)
      @args = args
      self.check_required
      self.validate
      self.main
    end

    def self._required_init
      @required = []
    end

    def self.check_required
      self._required_init
      missing = []
      @required.each do |key|
        if ! @args.key?(key)
           missing << "--#{key}"
        end
      end

      if missing.any?
        puts "missing arg(s): #{missing.join(", ")}"
        exit 1
      end

    end

    def self.validate
      self._if_exists(self._get_source_path)
      @args['include'].each do |repo|
        self._if_exists(self._get_source_file_path(repo))
      end
    end

    def self._if_exists(file_or_dir)
      if ! File.exist?(file_or_dir)
        puts "#{file_or_dir} does not exist"
        exit 1
      end
    end

    def self.main
      puts "oops, `self.main` hasn't been overridden in child class!"
      exit 1
    end

    def self._get_source_path()
      return "#{$repomanroot}/templates/#{@args['distro'].split(/(\d+)/).join('/')}"
    end

    def self._get_source_file_path(file)
      # Split distro at integer and join back together with /
      #return "#{$repomanroot}/templates/#{@args['distro'].split(/(\d+)/).join('/')}/#{file}"
      return "#{self._get_source_path}/#{file}"
    end

  end

  class Generate < Base
    def self._required_other
      @required = ['distro', 'include', 'outfile']
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
      if ! @args['conf']
        @required = ['reporoot']
      else
        @required = ['distro', 'include', 'reporoot']
      end
    end

    def self.main
      @repoconf = @args['reporoot'] + '/mirror.conf'
      self.setup_repo
      # Loop through each repository defined in file
      File.read(@repoconf).scan(/(?<=name=).*/).each do |repo|
        self.sync_repo(repo)
        self.generate_metadata(repo)
      end
    end

    def self.setup_repo
      if @args['conf']

        # Create reporoot if it doesn't exist
        if ! File.directory?(@args['reporoot'])
          begin
            FileUtils::mkdir_p @args['reporoot']

            rescue SystemCallError
              puts "An error occurred when creating #{@args['reporoot']}, most likely the user has insufficient permissions to create the directory"
              exit 1
          end
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
      else
        self._if_exists(@repoconf)
      end
    end

    def self.sync_repo(repo)
      if @args['mirror']
        puts "Syncing #{repo}"
        %x(reposync -nm --config #{@repoconf} -r #{repo} -p #{self._get_repo_path(repo)} --norepopath)
        if repo.include?('base')
          puts "Downloading pxeboot files"
          source_url = %x(yum --config #{@repoconf} repoinfo #{repo}).scan(/(?<=baseurl : ).*/)[0]
          %x(wget -q -N #{source_url}/images/pxeboot/{initrd.img,vmlinuz} -P #{self._get_repo_path(repo)}/images/pxeboot/)
        end
      end
    end

    def self.generate_metadata(repo)
      if @args['meta']
        group_data = if File.file?(self._get_repo_path(repo) + '/comps.xml') then '-g comps.xml' else '' end
        puts "Generating metadata for #{repo}"
        %x(createrepo #{group_data} #{self._get_repo_path(repo)})
      end
    end

    def self._get_repo_path(reponame)
      # Split distro at integer and join back together with /
      return "#{@args['reporoot']}/#{reponame.split(/-/).join('/')}/"
    end
  end

end
