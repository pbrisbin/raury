require 'raury/exceptions'
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
        options, arguments = parse_options(argv)

        Dir.chdir(options[:build_dir])

        if method = options[:search]

          search = Search.new(*arguments)
          search.send(method)

        elsif options[:sync]

          if options[:upgrade]
            Upgrades.process(options[:level])
          else
            plan = BuildPlan.new(options[:level], arguments)
            plan.resolve_dependencies! if options[:resolve]
            plan.run! if plan.continue?
          end

        else raise InvalidUsage
        end

      rescue => ex
        msg = case ex
              when InvalidUsage then 'invalid usage. try -h or --help'
              when NoTargets    then 'no targets specified (use -h for help)'
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
          opts.on('-S', '--sync',     'Install packages')       { options[:sync]    = true      }
          opts.on('-u', '--upgrade',  'Upgrade packages')       { options[:upgrade] = true      }
          opts.on('-d', '--download', 'Stop after downloading') { options[:level]   = :download }
          opts.on('-e', '--extract',  'Stop after extracting')  { options[:level]   = :extract  }
          opts.on('-b', '--build',    'Stop after building')    { options[:level]   = :build    }

          # searching
          opts.on('-s', '--search', 'Search for packages')      { options[:search] = :search }
          opts.on('-i', '--info',   'Show info for packages')   { options[:search] = :info   }
          opts.on('-q', '--quiet',  'Print only package names') { options[:quiet]  = true    }

          # configuration, TODO: opts/config file
          options[:build_dir] = '/tmp/raury'
          options[:resolve]   = true
          options[:show]      = false
          options[:edit]      = :never

        end.parse!(argv)

        [options, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end

    end
  end
end
