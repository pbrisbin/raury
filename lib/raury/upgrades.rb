module Raury
  # Find available upgrades to foreign packages.
  class Upgrades
    class << self
      include Output
      include Pacman
      include Threads

      # add available upgrades to the build plan as additional results.
      def add_to(plan)
        debug("checking available versions of foreign packages")

        each_threaded(pacman_Qm) do |name,version|
          if Config.development_pkg?(name)
            debug("ignoring #{name} due to development regex")
            next
          end

          local_result  = Result.new(:info, {"Name" => name, "Version" => version})
          remote_result = Rpc.new(:info, name).call rescue nil

          debug("installed: #{local_result}, available: #{remote_result || 'none'}")
          if remote_result && remote_result.newer?(local_result)
            debug("adding to build plan: #{local_result} => #{remote_result}")
            plan.results << remote_result # TODO: risk of duplicating targets?
          end
        end
      end
    end
  end
end
