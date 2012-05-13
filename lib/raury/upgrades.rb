module Raury
  class Upgrades
    def self.process(level)

      local_results = `pacman -Qm`.split("\n").map do |line|
        name, version = line.split(' ')

        Result.new(:multiinfo, {"Name" => name, "Version" => version})
      end

      up_to_date! if local_results.empty?

      results = []
      threads = []

      local_results.each do |local_result|
        threads << Thread.new do
          result = Rpc.new(:info, local_result.name).call rescue nil

          if result && Vercmp.new(result.version) > Vercmp.new(local_result.version)
            results << result
          end
        end
      end

      threads.map(&:join)

      if results.empty?
        puts 'there is nothing to do'
        exit
      end

      bp = BuildPlan.new(level, [])
      bp.set_results(results)

      bp.run! if bp.continue?
    end
  end
end
