require 'raury/exceptions'
require 'raury/aur'
require 'raury/result'
require 'raury/rpc'
require 'raury/download'
require 'raury/build'
require 'raury/build_plan'
require 'raury/depends'

require 'optparse'

module Raury
  # Raury::Main.run! ARGV
  class Main
    class << self

      def run!(argv)
        options, arguments = parse_options(argv)

        if search_method = options[:search]
          results = Rpc.new(search_method, *arguments).call

          options[:quiet] ? puts(*results.map(&:name))
                          :       results.map(&:display)

        elsif options[:sync]
          plan = build_plan(arguments, options)

          # TODO: continue [Y/n]?

          results = Rpc.new(:multiinfo, *plan.targets.reverse).call

          # download/extract all targets
          results.each do |result|
            if options[:level] == :download
              Download.new(result).download
            else
              Download.new(result).extract
            end
          end

          return if [:download, :extract].include?(options[:level])

          results.each do |result|
            if options[:level] == :build
              Build.new(result.name).build(['-s'])
            else
              Build.new(result.name).build(['-s', '-i'])
            end
          end

        else raise InvalidUsage
        end

      rescue => ex
        msg = case ex
              when InvalidUsage then 'invalid usage. try -h or --help'
              when NoResults    then 'no results found.'
              when NetworkError then 'there was a network error talking to the AUR'
              else "unhandled exception: #{ex}"
              end

        $stderr.puts "error: #{msg}"
        $stderr.puts "#{ex.backtrace.join("\n")}"
        exit 1
      end

      private

      # OptionParser wrapper. returns hash of options and remaining
      # arguments.
      def parse_options(argv)
        options = {}

        OptionParser.new do |opts|
          opts.banner = 'usage: raury [options] [arguments] ...'

          opts.on('-h', '--help', 'Display this screen') do
            puts opts
            exit
          end

          # installations
          opts.on('-S', '--sync',     'Install packages')       { options[:sync]   = true      }
          opts.on('-d', '--download', 'Stop after downloading') { options[:level]  = :download }
          opts.on('-e', '--extract',  'Stop after extracting')  { options[:level]  = :extract  }
          opts.on('-b', '--build',    'Stop after building')    { options[:level]  = :build    }

          # searching
          opts.on('-s', '--search', 'Search for packages')      { options[:search] = :search    }
          opts.on('-i', '--info',   'Show info for packages')   { options[:search] = :multiinfo }
          opts.on('-q', '--quiet',  'Print only package names') { options[:quiet]  = true       }

          # configuration
          # TODO:

        end.parse!(argv)

        [options, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end

      def build_plan(targets, options)
        if [:download, :extract].include?(options[:level])
          return BuildPlan.new(targets)
        end

        puts "resolving dependencies..."
        BuildPlan.new.tap do |plan|
          targets.each do |target|
            Depends.resolve(target, plan, options[:level] == :build)
          end
        end
      end

    end
  end
end
