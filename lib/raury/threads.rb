module Raury
  module Threads
    def each_threaded(arr, &block)
      threads = []

      arr.each do |i|
        threads << Thread.new { yield i }
      end

      threads.map(&:join)
    end
  end
end
