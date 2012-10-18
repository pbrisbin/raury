require 'raury/exceptions'

module Raury
  autoload :Aur,         'raury/aur'
  autoload :Build,       'raury/build'
  autoload :Config,      'raury/config'
  autoload :Depends,     'raury/depends'
  autoload :Download,    'raury/download'
  autoload :Exceptions,  'raury/exceptions'
  autoload :Options,     'raury/options'
  autoload :Output,      'raury/output'
  autoload :Pacman,      'raury/pacman'
  autoload :Parser,      'raury/parser'
  autoload :Plan,        'raury/plan'
  autoload :Prompt,      'raury/prompt'
  autoload :Result,      'raury/result'
  autoload :Rpc,         'raury/rpc'
  autoload :Search,      'raury/search'
  autoload :Threads,     'raury/threads'
  autoload :Upgrades,    'raury/upgrades'
  autoload :Vercmp,      'raury/vercmp'
  autoload :Version,     'raury/version'

  class Main
    class << self
      include Output

      def run!(argv)
        command, arguments = Options.parse!(argv)

        debug_box do
          debug("command: #{command}")
          debug("arguments: #{arguments}")
          debug("#{Config.config.map {|k,v| "#{k}: #{v}"}.join("\n")}")
        end

        raise InvalidUsage unless command

        if [:search, :info].include?(command)
          Search.new(arguments).send(command)
        else
          Dir.chdir(Config.build_directory) do
            Plan.new(arguments).send(command)
          end
        end

      rescue => ex
        error "#{ex}"

        debug_box do
          debug("trace:")
          debug("#{ex.backtrace.join("\n")}")
        end

        exit 1
      end
    end
  end
end
