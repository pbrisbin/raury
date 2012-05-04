require 'raury/exceptions'
require 'raury/aur'
require 'raury/result'
require 'raury/rpc'
require 'raury/search'
require 'raury/info'
require 'raury/output'

require 'optparse'

module Raury
  class Main

    def self.run!(argv)
      main = new(argv)

      if search = main.options[:search]
        quiet = main.options[:quiet]

        case search
        when :search
          results = Search.new(*main.arguments).call
          output  = Output.new(results)
          output.search unless quiet
        when :info
          results = Info.new(*main.arguments).call
          output  = Output.new(results)
          output.info unless quiet
        when :pkgbuild
          results = Info.new(*main.arguments).call
          output  = Output.new(results)
          output.pkgbuild unless quiet
        else
          raise InvalidUsage
        end

        output.quiet if quiet

      else
        # TODO: installation commands
      end

    rescue InvalidUsage
      $stderr.puts 'invalid usage. try -h or --help'
      exit 1

    rescue NoResults
      $stderr.puts 'no results found.'
      exit 1

    rescue NetworkError
      $stderr.puts 'there was a network error talking to the AUR'
      exit 1
    end

    attr_reader :options, :arguments

    def initialize(argv)
      @options = {}

      OptionParser.new do |opts|
        opts.banner = 'usage: rarury [options] [arguments] ...'

        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end

        opts.on('-s', '--search', 'Search for packages') do
          @options[:search] = :search
        end

        opts.on('-i', '--info', 'Show extended info on packages') do
          @options[:search] = :info
        end

        opts.on('-p', '--print', 'Print PKGBUILDs for packages') do
          @options[:search] = :pkgbuild
        end

        opts.on('-q', '--quiet', 'Show only names in output') do
          @options[:quiet] = true
        end
      end.parse!(argv)

      @arguments = argv

    rescue OptionParser::InvalidOption
      raise InvalidUsage
    end

    private_class_method :new

  end
end

#Raury::Main.run! ['-s', 'aur', 'helper']
#Raury::Main.run! ['-i', 'aurget', 'cower']
#Raury::Main.run! ['-p', 'aurget', 'cower']
#Raury::Main.run! ['-s', '-q', 'aur', 'helper']
#Raury::Main.run! ['-p', '-q', 'aurget', 'cower']
#Raury::Main.run! ['-i', '-q', 'aurget', 'cower']
