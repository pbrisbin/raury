module Raury
  module Threads
    # yield each element in the array in a separate thread. the return
    # value is useless, this is done for the side effects.
    def each_threaded(arr, &block)
      arr.map do |i|

        Thread.new { yield i }

      end.map(&:join)
    end
  end
end
