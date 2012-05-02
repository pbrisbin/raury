module Raury
  class Runner
    attr_reader :command, :targets

    def initialize(command, targets)
      raise InvalidUsage if command.nil?
      raise InvalidUsage if targets.empty?

      @command = command
      @targets = targets
    end
  end
end
