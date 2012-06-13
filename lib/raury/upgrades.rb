module Raury
  # Find available upgrades to foreign packages.
  class Upgrades
    class << self
      include Output
      include Pacman
      include Threads

      # add available upgrades to the build plan as additional results.
      def add_to(plan)
        local_results = []

        pacman_Qm.each do |name,version|
          if Config.development_pkg?(name)
            debug("ignoring #{name} due to development regex")
          else
            local_results << Result.new(:info, {"Name" => name, "Version" => version})
          end
        end

        if local_results.any?
          debug("checking available versions of foreign packages")

          each_threaded(local_results) do |local_result|
            result = Rpc.new(:info, local_result.name).call rescue nil

            debug("installed: #{local_result}, available: #{result || 'none'}")
            if result && result.newer?(local_result)
              debug("adding to build plan: #{local_result} => #{result}")
              plan.results << result
            end
          end
        end
      end
    end
  end
end
