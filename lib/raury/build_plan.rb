module Raury
  class BuildPlan
    def initialize(targets = [])
      @targets = targets
    end

    def add_target(target)
      unless targets.include?(target)
        targets << target
        all << target
      end
    end

    def add_incidental(incidental)
      unless incidentals.include?(incidental)
        incidentals << incidental
        all << incidental
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

    def combine_with(other, *others)
      [:targets, :incidentals, :all].each do |sym|
        instance_variable_set("@#{sym}",
                              (send(sym) + other.send(sym)).uniq)
      end

      if others.any?
        combine_with(*others)
      end
    end
  end
end
