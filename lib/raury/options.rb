require 'optparse'

module Raury
  class Options
    class << self

      def parse!(argv)
        command = nil
        config  = Config.config

        OptionParser.new do |opts|
          opts.banner =  'usage: raury [command] [options] [arguments]'
          opts.separator ''
          opts.separator 'Commands:'
          opts.on(            '-S', '--sync',           'Process packages')        { command = :install }
          opts.on(            '-u', '--upgrade',        'Upgrade packages')        { command = :upgrade }
          opts.on(            '-s', '--search',         'Search for packages')     { command = :search  }
          opts.on(            '-i', '--info',           'Show info for packages')  { command = :info    }
          opts.separator ''
          opts.separator 'Options:'
          opts.on(            '-d', '--download',       'Stop after downloading')  { config['sync_level'] = :download }
          opts.on(            '-e', '--extract',        'Stop after extracting')   { config['sync_level'] = :extract  }
          opts.on(            '-b', '--build',          'Stop after building')     { config['sync_level'] = :build    }
          opts.on(            '-y', '--install',        'Install after building')  { config['sync_level'] = :install  }
          opts.separator ''
          opts.on(                  '--build-dir DIR',  'Set build directory')     { |d| config['build_directory'] = d }
          opts.on(                  '--ignore PKG',     'Ignore package')          { |p| config['ignores'] << p }
          opts.on(                  '--[no-]color',     'Colorize output')         { |b| config['color']   = b }
          opts.on(                  '--[no-]confirm',   'Auto-answer prompts')     { |b| config['confirm'] = b }
          opts.on(                  '--[no-]deps',      'Resolve dependencies')    { |b| config['resolve'] = b }
          opts.on(                  '--[no-]edit',      'Edit PKGBUILDs')          { |b| config['edit']    = b ? :always : :never }
          opts.separator ''
          opts.on(                  '--version',        'Show version')            { puts "raury #{VERSION}"; exit }
          opts.on(                  '--debug',          'Show debug output')       { config['debug'] = true }
          opts.separator ''
          opts.on(            '-h', '--help',           'Display this screen')     { puts opts; exit }
          opts.separator ''
          opts.separator 'These options can be passed to makepkg:'
          opts.separator ''
          mopt(opts, config,   '-c', '--clean',         'Clean up work files after build')
          mopt(opts, config,   '-f', '--force',         'Overwrite existing package')
          mopt(opts, config,   '-L', '--log',           'Log package build process')
          mopt(opts, config,   '-r', '--rmdeps',        'Remove installed dependencies after a successful build')
          mopt(opts, config,         '--asroot',        'Allow makepkg to run as root user')
          mopt(opts, config,         '--sign',          'Sign the resulting package with gpg')
          mopt(opts, config,         '--skipinteg',     'Do not perform any verification checks on source files')
          opts.separator ''

        end.parse!(argv)

        [command, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end

      private

      def mopt(opts, config, *args)
        opts.on(*args) { config['makepkg_options'] << args.first }
      end

    end
  end
end
