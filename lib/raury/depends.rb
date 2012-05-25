require 'cgi'

module Raury
  # Recursively resolve dependencies.
  class Depends
    extend Pacman

    # resolve for name and add additional targets to the build plan.
    def self.resolve(name, bp)
      if deps = depends(name, Config.sync_level == :build)
        bp.add_target(name)

        if deps.any?
          [].tap do |ts|
            (deps - bp.targets).each do |dep|
              ts << Thread.new { resolve(dep, bp) }
            end
          end.map(&:join)
        end
      end
    end

    # download a PKGBUILD directly to a bash process which outputs the
    # (make)depends arrays one item per line. returns nil if the
    # PKGBUILD is not found.
    #
    # *use --no-deps if this makes you nervous*
    #
    def self.depends(name, build_only = false)
      return nil if checked?(name)

      pkg = CGI::escape(name)
      pkgbuild = Aur.new("/packages/#{pkg.slice(0,2)}/#{pkg}/PKGBUILD").fetch

      return nil if pkgbuild =~ /not found/i

      deps = IO.popen('bash', 'r+') do |h|
        h.write(%{
#{pkgbuild}
printf "%s\\n" "${makedepends[@]}"#{build_only ? '' : ' "${depends[@]}"'}
        })

        h.close_write
        h.read.split("\n")
      end

      pacman_T deps
    end

    # holds values we've already checked so we don't repeatedly check
    # them in cases where dependencies are shared.
    def self.checked?(name)
      @checked ||= []

      if @checked.include?(name)
        true
      else
        @checked << name
        false
      end
    end
  end
end
