module Raury
  class Output
    def initialize(search_results)
      @search_results = search_results
    end

    def search
      sorted_results.each do |result|
        puts "aur/#{result.name} #{result.version}#{result.out_of_date ? ' [out of date]' : ''}",
             "    #{result.description}"
      end
    end

    private

    def sorted_results
      if @search_results.length > 1
        @search_results.sort_by(&:name)
      else
        @search_results
      end
    end
  end
end
