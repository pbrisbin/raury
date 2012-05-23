module Raury
  class BuildPlan
    include Prompt
    include Output

    def initialize(targets = [])
      targets.each do |t|
        add_target(t)
      end
    end

    def add_target(target)
      unless targets.include?(target)
        if Config.ignore?(target)
          if prompt("#{target} is ignored. Process anyway")
            debug("adding #{target} to build_plan")
            targets << target
            all     << target
          else
            warn("skipping #{target}...")
          end
        else
          debug("adding #{target} to build_plan")
          targets << target
          all     << target
        end
      end
    end

    def add_incidental(incidental)
      unless incidentals.include?(incidental)
        debug("#{incidental} may be installed by pacman")
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
      puts 'resolving dependencies...'
      targets.each do |target|
        Depends.resolve(target, self)
      end
    end

    def results
      unless @results
        raise NoTargets if targets.empty?

        debug("fetching info for '#{targets.join(', ')}'")
        @results = Rpc.new(:multiinfo, *targets.reverse).call

        if @results.length != targets.length
          debug("not all targets available")
          raise NoResults.new((targets - @results.map(&:name)).first)
        end
      end

      @results
    end

    # used only in upgrades where we have all the results from the
    # version check.
    def set_results(results)
      @results = results
    end

    def run!
      puts 'searching the AUR...'
      puts '', "#{yellow "Targets (#{results.length}):"} #{results.map(&:to_s).join(' ')}"

      return unless prompt('Proceed with installation')

      level = Config.sync_level

      results.each do |result|
        if level == :download
          debug("downloading #{result}")
          Download.new(result).download
        else
          debug("extracting #{result}")
          Download.new(result).extract
        end
      end

      return if [:download, :extract].include?(level)

      results.each do |result|
        debug("building #{result}")
        Build.new(result.name).build
      end
    end
  end
end
