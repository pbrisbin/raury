module Raury
  # Handles the calls to your editor and makepkg. Adds appropriate
  # options based on configuration.
  class Build
    include Prompt
    include Output

    def initialize(package)
      @package = package
    end

    def build
      options = Config.makepkg_options.dup

      options << '--nocolor'   unless Config.color?
      options << '--noconfirm' unless Config.confirm?
      options << '-s' if Config.resolve?
      options << '-i' if Config.install?

      if Config.keep_devels? && Config.development_pkg?(@package)
        debug("#{@package} is development, removing any --clean option")
        options.delete('-c')
      end

      debug("building #{@package}")
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
