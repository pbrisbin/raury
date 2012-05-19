module Raury
  class Upgrades
    def self.build_plan
      local_results = `pacman -Qm`.split("\n").map do |line|
        name, version = line.split(' ')

        Result.new(:multiinfo, {"Name" => name, "Version" => version}) rescue []
      end

      results = []
      threads = []

      if local_results.any?
        local_results.each do |local_result|
          threads << Thread.new do
            result = Rpc.new(:info, local_result.name).call rescue nil

            if result && Vercmp.new(result.version) > Vercmp.new(local_result.version)
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
