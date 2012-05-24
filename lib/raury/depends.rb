require 'cgi'

module Raury
  class Depends
    extend Pacman

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

    def self.depends(name, build_only = false)
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
  end
end
