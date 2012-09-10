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
            if Config.devs?
              if result = Rpc.new(:info, name).call rescue nil
                debug("adding to build plan: #{result} (dev package)")
                plan.results << result
              end
            else
              debug("ignoring: #{name} (dev package)")
            end

            next
          end

          local  = Result.new(:info, {"Name" => name, "Version" => version})
          remote = Rpc.new(:info, name).call rescue nil

          debug("installed: #{local}, available: #{remote || 'none'}")
          if remote && remote.newer?(local)
            debug("adding to build plan: #{local} => #{remote}")
            plan.results << remote # TODO: risk of duplicating targets?
          end
        end
      end
    end
  end
end
