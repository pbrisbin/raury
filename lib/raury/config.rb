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
    DEFAULTS = { 'color'      => true,
                 'confirm'    => true,
                 'debug'      => false,
                 'edit'       => :prompt,
                 'editor'     => ENV['EDITOR'] || 'vim',
                 'ignores'    => [],
                 'resolve'    => false,
                 'sync_level' => :install,
                 'build_directory'   => ENV['HOME'],
                 'development_regex' => /-(git|hg|svn|darcs|-cvs|-bzr)$/,
                 'makepkg_options'   => [] }

    BOOLEANS = ['color', 'confirm', 'debug', 'resolve']
    SYMBOLS  = ['edit', 'sync_level']

    # delegate to our underlying hash of options
    def method_missing(meth, *args, &block)
      if config && config.has_key?(meth.to_s)
        config[meth.to_s]
      else
        super
      end
    end

    # add query methods for boolean settings
    BOOLEANS.each do |key|
      class_eval %[ def #{key}?; #{key} end ]
    end

    # cast some options to symbols
    SYMBOLS.each do |key|
      class_eval %[ def #{key}; config['#{key}'].to_sym end ]
    end

    def build_directory
      File.expand_path(config['build_directory'])
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
