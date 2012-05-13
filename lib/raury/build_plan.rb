module Raury
  class BuildPlan
    attr_reader :level

    def initialize(level, targets)
      @level   = level
      @targets = targets
    end

    def add_target(target)
      unless targets.include?(target)
        targets << target
        all     << target
      end
    end

    def add_incidental(incidental)
      unless incidentals.include?(incidental)
        incidentals << incidental
        all         << incidental
      end
    end

    def targets
      @targets ||= []
    end

    def incidentals
      @incidentals ||= []
    end

    def all
      @all ||= []
    end

    def resolve_dependencies!
      targets.each do |target|
        Depends.resolve(target, self)
      end
    end

    def results
      results = Rpc.new(:multiinfo, *targets.reverse).call

      if results.length != targets.length
        # TODO: error on unavailable targets
      end

      results
    end

    def continue?
      # TODO:
      return true
    end

    def run!
      results.each do |result|
        if level == :download
          Download.new(result).download
        else
          Download.new(result).extract
        end
      end

      return if [:download, :extract].include?(level)

      # TODO: edit pkgbuild?

      results.each do |result|
        if level == :build
          Build.new(result.name).build(['-s'])
        else
          Build.new(result.name).build(['-s', '-i'])
        end
      end
    end
  end
end
