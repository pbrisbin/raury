require 'cgi'

module Raury
  class Depends
    def self.resolve(name, bp)
      deps = depends(name, Config.sync_level == :build)
      deps ? bp.add_target(name) : bp.add_incidental(name)

      return if !deps || deps.empty?

      [].tap do |ts|
        (deps - bp.all).each do |dep|
          ts << Thread.new { resolve(dep, bp) }
        end
      end.map(&:join)
    end

    def self.depends(name, build_only = false)
      pkg = CGI::escape(name)
      pkgbuild = Aur.new("/packages/#{pkg.slice(0,2)}/#{pkg}/PKGBUILD").fetch

      return nil if pkgbuild =~ /not found/i

      # TODO: display pkgbuild, prompt: continue?

      deps = IO.popen('bash', 'r+') do |h|
        h.write(%{
#{pkgbuild}
printf "%s\\n" "${makedepends[@]}"#{build_only ? '' : ' "${depends[@]}"'}
        })

        h.close_write
        h.read.split("\n")
      end

      `pacman -T -- #{quote deps}`.split("\n").map {|d| d.sub(/(==?|>=|<=).*$/, '') }
    end

    private

    def self.quote(args)
      args.map { |arg| "'#{arg}'" }.join(' ')
    end
  end
end
