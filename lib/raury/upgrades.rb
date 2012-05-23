module Raury
  class Upgrades
    class << self
      include Output
      include Pacman

      def build_plan
        local_results = []

        pacman_Qm.each do |name,version|
          if (r = Config.development_regex) && name =~ r
            debug("ignoring #{name} due to development regex")
          else
            local_results << Result.new(:info, {"Name" => name, "Version" => version})
          end
        end

        results = []
        threads = []

        if local_results.any?
          local_results.each do |local_result|
            threads << Thread.new do
              debug("fetching info for #{local_result}")
              result = Rpc.new(:info, local_result.name).call rescue nil

              if result && Vercmp.new(result.version) > Vercmp.new(local_result.version)
                debug("available upgrade #{local_result} => #{result}")
                results << result
              end
            end
          end

          threads.map(&:join)
        end

        if results.empty?
          puts 'there is nothing to do'
          exit
        end

        BuildPlan.new.tap do |bp|
          bp.set_results(results.sort)
        end
      end
    end
  end
end
