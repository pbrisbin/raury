module Raury
  class Output
    def initialize(results)
      @results = results
    end

    def search
      results.each do |result|
        puts "aur/#{result.name} #{result.version}#{result.out_of_date ? ' [out of date]' : ''}",
             "    #{result.description}"
      end
    end

    def info
      results.each do |result|
        puts "Repository      : aur",
             "Name            : #{result.name}",
             "Version         : #{result.version}",
             "URL             : #{result.url}",
             "Out of date     : #{result.out_of_date ? 'Yes' : 'No'}",
             "Description     : #{result.description}", ''
      end
    end

    def quiet
      results.each do |result|
        puts result.name
      end
    end

    def pkgbuild
      results.each do |result|
        aur = Aur.new(
          File.join(File.dirname(result.pkg_url), 'PKGBUILD'))

        puts aur.fetch, ''
      end
    end

    private

    def results
      if @results.length > 1
        @results.sort_by(&:name)
      else
        @results
      end
    end
  end
end
