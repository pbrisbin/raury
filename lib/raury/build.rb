module Raury
  class Build
    def initialize(package)
      @package = package
    end

    def build(options = [])
      Dir.chdir(@package) do
        raise Errno::ENOENT unless File.exists?('PKGBUILD')

        unless system('makepkg', *options)
          raise BuildError.new(@package)
        end
      end

    rescue Errno::ENOENT
      raise NoPkgbuild.new(@package)
    end
  end
end
