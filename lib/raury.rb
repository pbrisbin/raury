# mixins
require 'raury/output'
require 'raury/pacman'
require 'raury/prompt'

# classes
require 'raury/aur'
require 'raury/build'
require 'raury/config'
require 'raury/depends'
require 'raury/download'
require 'raury/exceptions'
require 'raury/options'
require 'raury/plan'
require 'raury/result'
require 'raury/rpc'
require 'raury/search'
require 'raury/upgrades'
require 'raury/vercmp'
require 'raury/version'

module Raury
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

        if [:search, :info].include?(command)
          Search.new(*arguments).send(command)
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
