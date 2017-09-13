
module Commands
  
  class Base
    def run(args)
      puts 'running command'
      args
    end

    def _generate_config

    end

  end

  class Client < Base
  end

  class Server < Base
  end

end
