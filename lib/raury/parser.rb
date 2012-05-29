module Raury
  # Retrieves dependencies out of a given PKGBUILD.
  class Parser
    class << self
      # feed the pkgbuild through bash. obviously this comes with all
      # the risks of sourcing an unviewed PKGBUILD. however, it's the
      # only way to be 100% accurate.
      def source!(pkgbuild, build_only = false)
        # add a printf line to the script to output the (make)depends in
        # a parsable away (one per line)
        pkgbuild += "\n"
        pkgbuild += 'printf "%s\n" "${makedepends[@]}" '
        pkgbuild += '              "${depends[@]}"     '.strip unless build_only
        pkgbuild += "\n"

        IO.popen('bash', 'r+') do |h|
          h.write(pkgbuild)
          h.close_write
          h.read.split("\n")
        end
      end

      # use ruby to parse the (make)depends from the PKGBUILD string.
      # this is fairly accurately given well-formed PKGBUILDs and is
      # almost (but not quite) as fast as sourcing directly. however,
      # it's 100% safe to do.
      def parse!(pkgbuild, build_only = false)
        have_deps  = build_only
        have_mdeps = false

        lines = pkgbuild.dup.split("\n")

        [].tap do |arr|
          while line = lines.shift
            if line =~ /makedepends=(.*)/
              parse_bash_array!(arr, $1, lines)
              have_mdeps = true

              break if have_deps
            elsif line =~ /(?!make)depends=(.*)/
              unless build_only
                parse_bash_array!(arr, $1, lines)
                have_deps = true

                break if have_mdeps
              end
            end
          end
        end
      end

      private

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
end
