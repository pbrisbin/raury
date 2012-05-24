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

        debug("running #{command} #{arguments}")

        if [:search, :info].include?(command)
          Search.new(*arguments).send(command)
        else
          Dir.chdir(Config.build_directory) do
            debug("#{command}ing in #{Config.build_directory}")
            Plan.new(arguments).send(command)
          end
        end

      rescue => ex
        error "#{ex}"

        debug('')
        debug('-' * 80)
        debug("call stack: #{ex.backtrace.join("\n")}")

        exit 1
      end
    end
  end
end
