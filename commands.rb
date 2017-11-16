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
$repomanvar = '/var/lib/repoman'
$searchpaths = [$repomanvar, $repomanroot]

module Commands
  
  class Base
    
    def self.run(args)
      @args = args
      self.check_required
      @distro_path = @args['distro'].split(/(\d+)/).join('/')
      FileUtils::mkdir_p "#{$repomanvar}/templates/#{@distro_path}"
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
      self.validate_other
    end

    def self.validate_other
    end

    def self._if_exists(file_or_dir)
      if ! File.exist?(file_or_dir)
        return false
      else
        return true
      end
    end

    def self.main
      puts "oops, `self.main` hasn't been overridden in child class!"
      exit 1
    end

    def self.find_file(file)
      $searchpaths.each do |path|
        search = self._get_template_file_path(path, file)
        if self._if_exists(search)
          return search
        end
      end
      tmp = $searchpaths
      STDERR.puts "#{file} does not exist in search paths: #{tmp.map! {|word| "#{word}/templates/#{@distro_path}"} ; tmp.join(', ')}"
      exit 1
    end

    def self._get_template_file_path(path, file)
      return "#{path}/templates/#{@distro_path}/#{file}"
    end

    def self.mkdir_wrapper(dir)
      if ! File.directory?(dir)
        begin
          FileUtils::mkdir_p dir

          rescue SystemCallError
            STDERR.puts "An error occurred when creating #{dir}, most likely the user has insufficient permissions to  create the directory"
            exit 1
        end
      end
    end

  end

  class Show < Base

    def self.run()
      $searchpaths.each do |path|
        repofiles = Dir[path + '/templates/**/*'].reject {|fn| File.directory?(fn) }.map {|item| item.sub(/^.*\/templates\//, '') }
        puts "Available in #{path}: #{repofiles}"
      end
    end

  end

  class Generate < Base
    def self._required_init
      @required = ['distro', 'include', 'outfile']
    end

    def self.validate_other
    end

    def self.main
      sourcefiles = []
      @args['include'].each do |repo|
        sourcefiles << self.find_file(repo)
      end
      self.mkdir_wrapper(File.dirname(@args['outfile']))
      %x(cat #{sourcefiles.join(' ')} > #{@args['outfile']})
      puts "The file(s) #{sourcefiles.join(' ')} have been saved to #{@args['outfile']}"
    end

  end

  class Mirror < Base
    def self._required_init
      if ! @args['conf']
        @required = ['distro', 'reporoot', 'configurl']
      else
        @required = ['distro', 'include', 'reporoot', 'configurl']
      end
    end

    def self.validate_other
    end

    def self.main
      @repoconf = @args['reporoot'] + '/mirror.conf'
      self.setup_repo
      # Loop through each repository defined in file
      File.read(@repoconf).scan(/(?<=name=).*/).each do |repo|
        self.sync_repo(repo)
        self.generate_metadata(repo)
      end
      if @args['custom']
        self.generate_metadata('custom')
      end
      self.local_conf
    end

    def self.setup_repo
      if @args['conf']

        # Create reporoot if it doesn't exist
        self.mkdir_wrapper(@args['reporoot'])
        
        # Create repository directory
        if @args['custom']
          customrepo = @args['reporoot'] + '/custom'
          self.mkdir_wrapper(customrepo)
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
          sourcefile = self.find_file(file)
          File.write(@repoconf, %x(cat #{sourcefile}), File.size(@repoconf), mode: 'a')
        end
      else
        if ! self._if_exists(@repoconf)
          STDERR.puts "Existing repository config (#{@repoconf}) does not exist"
          exit 1
        end
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
          %x(wget -q -N #{source_url}/LiveOS/squashfs.img -P #{self._get_repo_path(repo)}/LiveOS/)
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

    def self.local_conf
      repolocal = if @args.key?("configout")
                    @args["configout"]
                  else
                    "#{$repomanvar}/templates/#{@distro_path}/local.repo"
                  end
      repoarray = File.read(@repoconf).split(/\n\n/)[1..-1]
      File.write(repolocal, '')
      repoarray.each do |config|
        repopath = config.scan(/(?<=name=).*/)[0].split(/-/).join('/')
        if repopath != 'custom'
          File.write(repolocal, config.gsub(/baseurl=.*/, "baseurl=#{@args['configurl']}/#{repopath}"), File.size(repolocal), mode: 'a')
          File.write(repolocal, "\n\n", File.size(repolocal), mode: 'a')
        end
      end
      if @args['custom']
        File.write(repolocal, "
[custom]
name=custom
baseurl=#{@args['configurl']}/custom
description=Custom repository
enabled=1
ski_if_unavailable=1
gpgcheck=0
priority=11

", File.size(repolocal), mode: 'a')
      end
      puts "The local repository config (for clients to use) has been saved to #{repolocal}"
    end

    def self._get_repo_path(reponame)
      # Split distro at integer and join back together with /
      return "#{@args['reporoot']}/#{reponame.split(/-/).join('/')}/"
    end
  end

end
