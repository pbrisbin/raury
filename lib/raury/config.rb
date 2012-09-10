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
    CONFIG_FILE = if ENV['XDG_CONFIG_HOME']
                    File.join(ENV['XDG_CONFIG_HOME'], 'rauryrc')
                  else
                    File.join(ENV['HOME'], '.rauryrc')
                  end

    # default behavior
    DEFAULTS = { 'color'             => :auto,
                 'confirm'           => true,
                 'debug'             => false,
                 'devs'              => false,
                 'edit'              => :prompt,
                 'editor'            => ENV['EDITOR'] || 'vim',
                 'ignores'           => [],
                 'quiet'             => false,
                 'resolve'           => false,
                 'source'            => false,
                 'sync_level'        => :install,
                 'build_directory'   => ENV['HOME'],
                 'development_regex' => /-(git|hg|svn|darcs|cvs|bzr)$/,
                 'keep_devels'       => false,
                 'makepkg_options'   => [] }

    # settings which should have query methods
    BOOLEANS = %w[confirm debug devs quiet resolve source keep_devels]

    # settings which should be symbols
    SYMBOLS = %w[color edit sync_level]

    # actions which occur at given sync_levels
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

    BOOLEANS.each do |key|
      class_eval %[ def #{key}?; #{key} end ]
    end

    SYMBOLS.each do |key|
      class_eval %[ def #{key}; config['#{key}'].to_sym end ]
    end

    LEVELS.each do |meth,levels|
      class_eval %[ def #{meth}?; #{levels}.include?(sync_level) end ]
    end

    # configured build directory path expanded
    def build_directory
      File.expand_path(config['build_directory'])
    end

    # is the package included in our ingores?
    def ignore?(pkg)
      ignores.include?(pkg)
    end

    # if color is auto, check if we're connected to a tty, otherwise
    # return true/false based on settings (always/never).
    def color?
      if color == :auto
        return $stdout.tty?
      end

      # ensure true on misconfigured value
      return color != :never
    end

    # if edit is prompt, prompt, otherwise return true/false based on
    # settings (always/never).
    def edit?(pkg)
      if edit == :prompt
        return prompt("Edit PKGBUILD for #{pkg}")
      end

      # ensure true on misconfigured value
      return edit != :never
    end

    # check package against development regex, if it exists
    def development_pkg?(pkg)
      if (r = development_regex) && pkg =~ r
        return true
      end

      false
    end

    # lazy-load the defaults hash merged with your yaml configuration
    # when present.
    def config
      unless @config
        yaml    = YAML::load(File.open(CONFIG_FILE)) rescue {}
        @config = DEFAULTS.merge(yaml)
      end

      @config
    end
  end
end
