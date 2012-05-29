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
          if (r = Config.development_regex) && name =~ r
            debug("ignoring #{name} due to development regex")
          else
            local_results << Result.new(:info, {"Name" => name, "Version" => version})
          end
        end

        if local_results.any?
          each_threaded(local_results) do |local_result|
            debug("checking available version for #{local_result}")
            result = Rpc.new(:info, local_result.name).call rescue nil

            if result && Vercmp.new(result.version) > Vercmp.new(local_result.version)
              debug("upgrade available: #{local_result} => #{result}")
              plan.results << result
            end
          end
        end
      end
    end
  end
end
