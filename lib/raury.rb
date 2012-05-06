require 'raury/exceptions'
require 'raury/aur'
require 'raury/result'
require 'raury/rpc'
require 'raury/download'
require 'raury/build'

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
        else
          # TODO: installation commands
        end

      rescue => ex
        msg = case ex
              when InvalidUsage then 'invalid usage. try -h or --help'
              when NoResults    then 'no results found.'
              when NetworkError then 'there was a network error talking to the AUR'
              else "unhandled exception: #{ex}"
              end

        $stderr.puts "error: #{msg}"
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

          opts.on('-s', '--search', 'Search for packages')         { options[:search] = :search    }
          opts.on('-i', '--info',   'Show info for packages')      { options[:search] = :multiinfo }
          opts.on('-q', '--quiet',  'Print only package names')    { options[:quiet]  = true       }
        end.parse!(argv)

        [options, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end

    end
  end
end
