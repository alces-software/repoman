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

require 'yaml'

module ConfigFile
  class Base

    def initialize(file)
      @file_path = file
      @config = YAML.load_file(@file_path)
      
    end

    def display
      @config.to_yaml
    end

    def write_to_config
      File.open(@file_path, 'w') do |conf|
        conf.write self.display
      end
    end

    def merge(hash)
      hash.each do |key, val|
        # TODO - at some sort of good validator
        if @config.key?(key)
          @config[key] = val
        end
      end
    end

  end
end
