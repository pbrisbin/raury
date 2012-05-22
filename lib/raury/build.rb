module Raury
  class Build
    include Prompt

    def initialize(package)
      @package = package
    end

    def build
      options = [].tap do |arr|
        arr << '--nocolor'   unless Config.color?
        arr << '--noconfirm' unless Config.confirm?
        arr << '-s' if Config.resolve?
        arr << '-i' if Config.sync_level == :install
      end

      Dir.chdir(@package) do
        raise Errno::ENOENT unless File.exists?('PKGBUILD')

        if edit?
          unless system("#{Config.editor} 'PKGBUILD'")
            raise EditError.new(@package)
          end

          return unless continue?
        end

        unless system('makepkg', *options)
          raise BuildError.new(@package)
        end
      end

    rescue Errno::ENOENT
      raise NoPkgbuild.new(@package)
    end

    private

    def edit?
      return true  if Config.edit == :always
      return false if Config.edit == :never

      prompt("Edit PKGBUILD for #{@package}")
    end

    def continue?
      prompt('Continue')
    end
  end
end
