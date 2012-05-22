require 'optparse'
require 'raury/prompt'
require 'raury/aur'
require 'raury/build'
require 'raury/build_plan'
require 'raury/config'
require 'raury/depends'
require 'raury/download'
require 'raury/exceptions'
require 'raury/result'
require 'raury/rpc'
require 'raury/search'
require 'raury/upgrades'
require 'raury/vercmp'
require 'raury/version'

module Raury
  class Main
    class << self
      def run!(argv)
        command, arguments = parse_options(argv)

        if Config.debug?
          puts '', '-' * 80
          puts "running '#{command}' with arguments '#{arguments.join(', ')}'"
          puts "configuration: #{Config.config.inspect}"
          puts '-' * 80, ''
        end

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
        $stderr.puts "error: #{ex}"

        if Config.debug?
          $stderr.puts '', '-' * 80
          $stderr.puts "#{ex.backtrace.join("\n")}"
          $stderr.puts '-' * 80, ''
        end

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
          opts.on(            '-S', '--sync',      'Process packages')        { command = :install }
          opts.on(            '-u', '--upgrade',   'Upgrade packages')        { command = :upgrade }
          opts.on(            '-s', '--search',    'Search for packages')     { command = :search  }
          opts.on(            '-i', '--info',      'Show info for packages')  { command = :info    }
          opts.separator ''
          opts.separator 'Options:'
          opts.on(            '-d', '--download',  'Stop after downloading')  { config['sync_level'] = :download }
          opts.on(            '-e', '--extract',   'Stop after extracting')   { config['sync_level'] = :extract  }
          opts.on(            '-b', '--build',     'Stop after building')     { config['sync_level'] = :build    }
          opts.on(            '-y', '--install',   'Install after building')  { config['sync_level'] = :install  }
          opts.separator ''
          opts.on(            '--build-dir DIR',   'Set build directory')     { |d| config['build_directory'] = d }
          opts.on(            '--ignore PKG',      'Ignore package')          { |p| config['ignores'] << p }
          opts.separator ''
          opts.on(            '--[no-]color',      'Colorize output')         { |b| config['color']   = b }
          opts.on(            '--[no-]confirm',    'Auto-answer prompts')     { |b| config['confirm'] = b }
          opts.on(            '--[no-]deps',       'Resolve dependencies')    { |b| config['resolve'] = b }
          opts.on(            '--[no-]discard',    'Discard sources')         { |b| config['discard'] = b }
          opts.on(            '--[no-]edit',       'Edit PKGBUILDs')          { |b| config['edit']    = b ? :always : :never }
          opts.separator ''
          opts.on(            '--version',         'Show version')            { puts "raury #{VERSION}"; exit }
          opts.on(            '--debug',           'Show debug output')       { config['debug'] = true }
          opts.separator ''
          opts.on(            '-h', '--help',      'Display this screen')     { puts opts; exit }
          opts.separator ''

        end.parse!(argv)

        [command, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end
    end
  end
end
