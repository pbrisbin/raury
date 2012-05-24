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
      debug("fetching info for #{targets}")
      results = Rpc.new(:multiinfo, *targets).call

      # we need the results in the reverse order of our targets (so
      # dependencies are installed first). unfortunately, the rpc
      # returns results alphabetically. assumption is the reordering
      # done here is cheaper than making per-target rpc calls.
      targets.reverse.each do |target|
        if result = results.detect {|r| r.name == target}
          debug("fetched info on #{result}")
          @results << result
        else
          debug("#{target} not found in #{results}")
          raise NoResults.new(target)
        end
      end
    end

    def run!(&block)
      raise NoResults if results.empty?

      puts ''
      puts "#{yellow "Targets (#{results.length}):"} #{results.map(&:to_s).join(' ')}"

      return unless prompt('Proceed with installation')

      results.each do |result|
        if Config.download?
          debug("downloading #{result}")
          Download.new(result).download
        else
          debug("extracting #{result}")
          Download.new(result).extract
        end
      end

      return unless Config.build?

      results.each do |result|
        debug("building #{result}")
        Build.new(result.name).build
      end
    end

    def sync(run = true)
      resolve_dependencies!
      fetch_results!

      run! if run
    end

    def upgrade
      sync(false) if targets.any?

      Upgrades.add_to(self)

      run!

    rescue NoResults
      puts 'there is nothing to do'
      exit
    end
  end
end
