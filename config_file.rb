
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
