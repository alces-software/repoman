require 'optparse'

class MainParser

  def self.parse(args)
    options = {}

    # Default options
    options['save'] = true
    options['mirror'] = true
    options['meta'] = true
    
    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: repoman COMMAND [OPTIONS]"
      opt.separator  ""
      opt.separator  "Commands"
      opt.separator  "    client: setup client repo config files"
      opt.separator  "    server: mirror upstream repos"
      opt.separator  ""
      opt.separator  "Options"

      opt.on("-s","--source SOURCE","which upstream repository should be used") do |source|
        options["source"] = source
      end

      opt.on("-d","--distro DISTRO","operating system to use") do |distro|
        options["distro"] = distro
      end

      opt.on("-r","--release VERSION",Numeric,"operating system version to use") do |version|
        options["version"] = version
      end

      opt.on("-h","--help","help") do
        puts opt
        exit
      end

      opt.on("--no-save","do not update config file with any settings changes") do |save|
        options['save'] = save
      end

      opt.on("--no-mirror","do not update repository packages [SERVER ONLY]") do |mirror|
        options['mirror'] = mirror
      end

      opt.on("--no-meta","do not update repository metadata [SERVER ONLY]") do |meta|
        options['meta'] = meta
      end
    end
    # Remove options from ARGV and store within opt_parser object
    opt_parser.parse!(args)
    
    # Return options
    return options
  end

end
