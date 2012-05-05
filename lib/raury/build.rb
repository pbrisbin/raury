module Raury
  class Build
    def initialize(package)
      @package = package
    end

    def build(options = [])
      Dir.chdir(@package) do
        raise NoPkgbuild unless File.exists?('PKGBUILD')

        unless system('makepkg', *options)
          raise BuildError
        end
      end

    rescue Errno::ENOENT
      raise NoPkgbuild
    end
  end
end
