module Raury
  # Holds the targets for the current build. Adds additional targets if
  # found as dependencies, confirms targets are available and executes
  # the download/build/install as needed.
  class Plan
    include Prompt
    include Output
    include Threads

    attr_reader :targets, :results

    def initialize(ts = [])
      @targets = ts
      @results = []
    end

    # add any dependencies for the current targets list as additional
    # targets.
    def resolve_dependencies!
      return unless Config.resolve? && targets.any?

      puts 'resolving dependencies...'
      each_threaded(targets) do |target|
        Depends.resolve(target, self)
      end
    end

    # creates an array of aur results which can be downloaded and built.
    # raises appropriate errors if we've got no targets to process or
    # any of our targets are unavailable.
    def fetch_results!
      raise NoTargets if targets.empty?

      targets.uniq!

      puts 'searching the AUR...'
      results = Rpc.new(:multiinfo, *targets).call

      # we need the results in the order of our targets (so dependencies
      # are installed first). unfortunately, the rpc returns results
      # alphabetically. assumption is the reordering done here is
      # cheaper than making per-target rpc calls.
      targets.each do |target|
        if result = results.detect {|r| r.name == target}
          @results << result
        else
          raise NoResults.new(target)
        end
      end
    end

    # prompt the user with the results that we'll process, when
    # confirmed, processes the results as per the current configuration.
    def run!
      prune_ignored!

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

    # process targets
    def sync
      resolve_dependencies!
      fetch_results!

      run!
    end

    # process targets if present, add any available upgrades and process
    # those as well.
    def upgrade
      if targets.any?
        resolve_dependencies!
        fetch_results!
      end

      Upgrades.add_to(self)

      run!
    end

    private

    # to provide consistent behavior re: ignored packages between
    # installs and upgrades, we check the final result set on its own
    # just before presenting the list for confirmation.
    def prune_ignored!
      ignored = []

      results.each do |result|
        if Config.ignore?(result.name) && !prompt("#{result.name} is ignored. Process anyway")
          warn("skipping #{result.name}...")
          ignored << result
        end
      end

      ignored.each { |i| results.delete(i) }
    end
  end
end
