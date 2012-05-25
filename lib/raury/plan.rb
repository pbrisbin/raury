module Raury
  class Plan
    include Prompt
    include Output

    attr_reader :targets, :results

    def initialize(ts = [])
      @targets = []
      @results = []

      # go through add_target so we can check ignores
      ts.each { |t| add_target(t) }
    end

    def add_target(target)
      unless targets.include?(target)
        if !Config.ignore?(target) || prompt("#{target} is ignored. Process anyway")
          debug("adding #{target} to build plan")
          targets << target
        else
          warn("skipping #{target}...")
        end
      end
    end

    def resolve_dependencies!
      return unless Config.resolve? && targets.any?

      puts 'resolving dependencies...'
      targets.each do |target|
        Depends.resolve(target, self)
      end
    end

    def fetch_results!
      raise NoTargets if targets.empty?

      targets.uniq!

      puts 'searching the AUR...'
      results = Rpc.new(:multiinfo, *targets).call

      # we need the results in the reverse order of our targets (so
      # dependencies are installed first). unfortunately, the rpc
      # returns results alphabetically. assumption is the reordering
      # done here is cheaper than making per-target rpc calls.
      targets.reverse.each do |target|
        if result = results.detect {|r| r.name == target}
          @results << result
        else
          raise NoResults.new(target)
        end
      end
    end

    def run!(&block)
      if results.empty?
        # the only way we get here without having raised NoTargets is if
        # we're checking for upgrades and there were none.
        puts 'there is nothing to do'
        exit
      end

      puts ''
      puts "#{yellow "Targets (#{results.length}):"} #{results.map(&:to_s).join(' ')}"

      return unless prompt('Proceed with installation')

      results.each do |result|
        if Config.download?
          Download.new(result).download
        else
          Download.new(result).extract
        end
      end

      return unless Config.build?

      results.each do |result|
        Build.new(result.name).build
      end
    end

    def sync
      resolve_dependencies!
      fetch_results!

      run!
    end

    def upgrade
      if targets.any?
        resolve_dependencies!
        fetch_results!
      end

      Upgrades.add_to(self)

      run!
    end
  end
end
