require 'singleton'
require 'yaml'

module Raury
  class Config
    include Singleton

    # delegate to our singleton instance
    def self.method_missing(meth, *args, &block)
      self.instance.send(meth, *args, &block)
    end

    # user config file location
    CONFIG_FILE = File.join(ENV['HOME'], '.rauryrc')

    # default behavior
    DEFAULTS = { 'debug'     => false,
                 'discard'   => false,
                 'edit'      => :never,
                 'editor'    => ENV['EDITOR'] || 'vim',
                 'ignores'   => [],
                 'resolve'   => true,
                 'sync_level'=> :install,
                 'build_directory' => ENV['HOME'],
                 'makepkg_options' => [],
                 'pacman_options'  => [] }

    # delegate to our underlying hash of options
    def method_missing(meth, *args, &block)
      if config && config.has_key?(meth.to_s)
        config[meth.to_s]
      else
        super
      end
    end

    def debug?
      debug
    end

    def descard?
      discard
    end

    def resolve?
      resolve
    end

    def ignore?(pkg)
      ignores.include?(pkg)
    end

    def config
      unless @config
        if yaml = YAML::load(File.open(CONFIG_FILE)) rescue nil
          @config = DEFAULTS.merge(yaml)
        else
          @config = DEFAULTS
        end
      end

      @config
    end
  end
end
