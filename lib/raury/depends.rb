require 'cgi'

module Raury
  # Recursively resolve dependencies.
  class Depends
    class << self
      include Pacman
      include Output
      include Threads

      # resolve for name and add additional targets to the build plan.
      def resolve(name, bp)
        if deps = depends(name, Config.sync_level == :build)
          bp.add_target(name)

          if deps.any?
            each_threaded(deps - bp.targets) do |dep|
              resolve(dep, bp)
            end
          end
        end
      end

      # retrieve the (make)depends for a package by either sourcing or
      # parsing its PKGBUILD depending on current configuration.
      def depends(name, build_only = false)
        return nil if checked?(name)

        pkg = CGI::escape(name)
        pkgbuild = Aur.new("/packages/#{pkg.slice(0,2)}/#{pkg}/PKGBUILD").fetch

        deps = if Config.source?
                 Parser.source!(pkgbuild, build_only)
               else
                 Parser.parse!(pkgbuild, build_only)
               end

        pacman_T deps

      rescue NetworkError => ex
        debug("#{name}, nework error: #{ex}")

        nil
      end

      # holds values we've already checked so we don't repeatedly check
      # them in cases where dependencies are shared.
      def checked?(name)
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
end
