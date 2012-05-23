module Raury
  class Upgrades
    class << self
      include Output

      def build_plan
        local_results = `pacman -Qm`.split("\n").map do |line|
          name, version = line.split(' ')

          if name =~ Config.development_regex
            debug("ignoring #{name} due to development regex")
          else
            Result.new(:multiinfo, {"Name" => name, "Version" => version}) rescue []
          end

        end.compact

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

        bp = BuildPlan.new
        bp.set_results(results.sort)

        bp
      end
    end
  end
end
