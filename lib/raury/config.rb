require 'singleton'
require 'yaml'

module Raury
  class Config
    include Singleton
    include Prompt

    # delegate to our singleton instance
    def self.method_missing(meth, *args, &block)
      self.instance.send(meth, *args, &block)
    end

    # user config file location
    CONFIG_FILE = File.join(ENV['HOME'], '.rauryrc')

    # default behavior
    DEFAULTS = { 'color'      => :auto,
                 'confirm'    => true,
                 'debug'      => false,
                 'edit'       => :prompt,
                 'editor'     => ENV['EDITOR'] || 'vim',
                 'ignores'    => [],
                 'resolve'    => false,
                 'sync_level' => :install,
                 'build_directory'   => ENV['HOME'],
                 'development_regex' => /-(git|hg|svn|darcs|cvs|bzr)$/,
                 'makepkg_options'   => [] }

    BOOLEANS = ['confirm', 'debug', 'resolve']

    SYMBOLS = ['color', 'edit', 'sync_level']

    LEVELS = { :download => [ :download                  ],
               :extract  => [ :extract, :build, :install ],
               :build    => [           :build, :install ],
               :install  => [                   :install ] }

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

    # add query methods around sync level
    LEVELS.each do |meth,levels|
      class_eval %[ def #{meth}?; #{levels}.include?(sync_level) end ]
    end

    def build_directory
      File.expand_path(config['build_directory'])
    end

    def ignore?(pkg)
      ignores.include?(pkg)
    end

    def color?
      if color == :auto
        return $stdout.tty?
      end

      # ensure true on misconfigured value
      return color != :never
    end

    def edit?(pkg)
      if edit == :prompt
        return prompt("Edit PKGBUILD for #{pkg}")
      end

      # ensure true on misconfigured value
      return edit != :never
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
