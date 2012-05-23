module Raury
  class Build
    include Prompt
    include Output

    def initialize(package)
      @package = package
    end

    def build
      options = Config.makepkg_options

      options << '--nocolor'   unless Config.color?
      options << '--noconfirm' unless Config.confirm?
      options << '-s' if Config.resolve?
      options << '-i' if Config.install?

      Dir.chdir(@package) do
        raise Errno::ENOENT unless File.exists?('PKGBUILD')

        if Config.edit?(@package)
          debug("running '#{Config.editor} PKGBUILD'")
          unless system("#{Config.editor} 'PKGBUILD'")
            debug("editor returned #{$?}")
            raise EditError.new(@package)
          end

          return unless prompt('Continue')
        end

        debug("running 'makepkg #{options.join(' ')}'")
        unless system('makepkg', *options)
          debug("makepkg returned #{$?}")
          raise BuildError.new(@package)
        end
      end

    rescue Errno::ENOENT
      raise NoPkgbuild.new(@package)
    end
  end
end
