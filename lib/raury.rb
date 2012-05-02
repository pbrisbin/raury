require 'raury/exceptions'
require 'raury/runner'

module Raury
  def self.new(*args)
    command = nil
    targets = []

    while arg = args.shift
      case arg
      when '-S'
        command = :install

      when /^-/
        raise InvalidUsage
      else
        targets << arg
      end
    end

    Runner.new(command, targets)

  rescue InvalidUsage
    $stderr.puts 'invalid usage, try -h or --help.'
    exit 1
  end
end
