module Raury
  class Upgrades
    class << self
      include Output
      include Pacman

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
          threads = []

          local_results.each do |local_result|
            threads << Thread.new do
              debug("checking available version for #{local_result}")
              result = Rpc.new(:info, local_result.name).call rescue nil

              if result && Vercmp.new(result.version) > Vercmp.new(local_result.version)
                debug("upgrade available: #{local_result} => #{result}")
                plan.results << result
              end
            end
          end

          threads.map(&:join)
        end
      end
    end
  end
end
