module Raury
  # Utility class used when results need to be printed. Centralizes
  # formatting and will eventually handle colourization.
  class Output
    def initialize(results)
      @results = results
    end

    # output to match pacman -Ss
    def search
      results.each do |result|
        puts "aur/#{result.name} #{result.version}#{result.out_of_date ? ' [out of date]' : ''}",
             "    #{result.description}"
      end
    end

    # output to match pacman -Si
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

    # output to match pacman -Ssq
    def quiet
      results.each do |result|
        puts result.name
      end
    end

    # print pkgbuilds for results on stdout
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
