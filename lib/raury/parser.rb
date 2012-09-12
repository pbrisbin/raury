module Raury
  # Retrieves dependencies out of a given PKGBUILD.
  class Parser
    attr_reader :pkgbuild

    def initialize(pkgbuild)
      @pkgbuild = pkgbuild
    end

    # Unless we're allowing sourcing, try to parse the (make)depends
    # using ruby. This is 100% safe and suprisingly accurate.
    def parse!
      # feeling risky?
      return source! if Config.source?

      have_deps  = build_only?
      have_mdeps = false

      lines = pkgbuild.dup.split("\n")

      [].tap do |arr|
        while line = lines.shift
          if line =~ /makedepends=(.*)/
            parse_bash_array!(arr, $1, lines)
            have_mdeps = true

            break if have_deps
          elsif line =~ /(?!make)depends=(.*)/
            unless build_only?
              parse_bash_array!(arr, $1, lines)
              have_deps = true

              break if have_mdeps
            end
          end
        end
      end
    end

    # Feed the PKGBUILD through bash. 100% accurate but dangerous. Also,
    # if bash throws an exception we cannot catch it and we die.
    def source!
      IO.popen('bash', 'r+') do |h|
        h.puts(pkgbuild)

        h.write('printf "%s\n" "${makedepends[@]}" ')
        h.write('              "${depends[@]}"     '.strip) unless build_only?
        h.puts

        h.close_write
        h.read.split("\n")
      end
    end

    private

    def build_only?
      Config.sync_level == :build
    end

    def parse_bash_array!(arr, line, lines)
      while !line.include?(')')
        line += ' ' + lines.shift.sub(/#.*/, '')
      end

      if line =~ /\((.*)\)/
        $1.strip.split(' ').map do |elem|
          arr << (elem =~ /('|")(.*)\1/ ? $2 : elem)
        end
      end
    end
  end
end
