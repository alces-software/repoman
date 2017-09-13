
require 'yaml'

module ConfigFile
  class ConfigBase

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

    def merge(yaml)
      puts 'merging CLI options into config file'
    end

  end
end
