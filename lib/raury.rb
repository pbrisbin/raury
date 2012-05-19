require 'raury/exceptions'
require 'raury/config'
require 'raury/aur'
require 'raury/result'
require 'raury/rpc'
require 'raury/search'
require 'raury/download'
require 'raury/build'
require 'raury/build_plan'
require 'raury/depends'
require 'raury/vercmp'
require 'raury/upgrades'

require 'optparse'

module Raury
  class Main
    class << self

      def run!(argv)
        command, arguments = parse_options(argv)

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
          plan.run! if plan.continue?
        end

      rescue => ex
        $stderr.puts "error: #{ex}"

        $stderr.puts '', '-' * 80
        $stderr.puts "#{ex.backtrace.join("\n")}"
        $stderr.puts '-' * 80, ''
        exit 1
      end

      private

      def parse_options(argv)
        command = nil
        config  = Config.config

        OptionParser.new do |opts|
          opts.banner =  'usage: raury [command] [options] [arguments]'
          opts.separator ''
          opts.separator 'Commands:'
          opts.on(            '-S', '--sync',      'Process packages')       { command = :install }
          opts.on(            '-u', '--upgrade',   'Upgrade packages')       { command = :upgrade }
          opts.on(            '-s', '--search',    'Search for packages')    { command = :search  }
          opts.on(            '-i', '--info',      'Show info for packages') { command = :info    }
          opts.separator ''
          opts.separator 'Options:'
          opts.on(            '-d', '--download',  'Stop after downloading') { config['sync_level'] = :download }
          opts.on(            '-e', '--extract',   'Stop after extracting')  { config['sync_level'] = :extract  }
          opts.on(            '-b', '--build',     'Stop after building')    { config['sync_level'] = :build    }
          opts.on(            '-y', '--install',   'Install after building') { config['sync_level'] = :install  }
          opts.on(            '--build-dir DIR',   'Set build directory')    { |d| config['build_directory'] = d }
          opts.on(            '--ignore PKG',      'Ignore package')         { |p| config['ignores'] << p }
          opts.on(            '--[no-]edit',       'Edit PKGBUILDs')         { |b| config['edit'] = b ? :always : :never }
          opts.on(            '--[no-]deps',       'Resolve dependencies')   { |b| config['resolve'] = b }
          opts.on(            '--[no]-discard',    'Discard sources')        { |b| config['discard'] = b }
          opts.separator ''
          opts.on(            '-h', '--help',      'Display this screen') do
            puts opts
            exit
          end

        end.parse!(argv)

        [command, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end

    end
  end
end

Raury::Main.run! %w( -Syu )
