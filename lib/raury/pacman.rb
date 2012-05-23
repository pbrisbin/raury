module Raury
  module Pacman
    VERSION_REGEX = /(==?|>=|<=).*$/

    # returns array of foriegn packages. packages are represented as a
    # two-element array, package and version.
    def pacman_Qm
      `pacman -Qm`.split("\n").map {|l| l.split(' ')}
    end

    # returns unsatisfied dependencies with version information
    # stripped.
    def pacman_T(args)
      `pacman -T -- #{quote args}`.split("\n").map {|d| d.sub(VERSION_REGEX, '')}
    end

    private

    def quote(args)
      args.map {|arg| "'#{arg}'"}.join(' ')
    end
  end
end
