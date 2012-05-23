# mixins
require 'raury/output'
require 'raury/pacman'
require 'raury/prompt'

# classes
require 'raury/aur'
require 'raury/build'
require 'raury/build_plan'
require 'raury/config'
require 'raury/depends'
require 'raury/download'
require 'raury/exceptions'
require 'raury/options'
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

        debug("running '#{command} #{arguments}'")

        if [:search, :info].include?(command)
          return Search.new(*arguments).send(command)
        end

        case command
        when :upgrade
          plan = Upgrades.build_plan
        when :install
          plan = BuildPlan.new(arguments)
          plan.resolve_dependencies! if Config.resolve?
        else
          raise InvalidUsage
        end

        Dir.chdir(Config.build_directory) do
          plan.run!
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
