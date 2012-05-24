require 'optparse'

module Raury
  class Options
    class << self

      def parse!(argv)
        command = nil
        conf    = Config.config

        OptionParser.new do |o|
          o.banner =  'usage: raury [command] [options] [arguments]'
          o.separator ''
          o.separator 'Commands:'
          o.on(            '-S', '--sync',           'Process packages')        { command = :sync    }
          o.on(            '-u', '--upgrade',        'Upgrade packages')        { command = :upgrade }
          o.on(            '-s', '--search',         'Search for packages')     { command = :search  }
          o.on(            '-i', '--info',           'Show info for packages')  { command = :info    }
          o.separator ''
          o.separator 'Options:'
          o.on(            '-d', '--download',       'Stop after downloading')  { conf['sync_level'] = :download }
          o.on(            '-e', '--extract',        'Stop after extracting')   { conf['sync_level'] = :extract  }
          o.on(            '-b', '--build',          'Stop after building')     { conf['sync_level'] = :build    }
          o.on(            '-y', '--install',        'Install after building')  { conf['sync_level'] = :install  }
          o.separator ''
          o.on(                  '--build-dir DIR',  'Set build directory')     { |d| conf['build_directory'] = d            }
          o.on(                  '--ignore PKG',     'Ignore package')          { |p| conf['ignores'] << p                   }
          o.on(                  '--[no-]color',     'Colorize output')         { |b| conf['color']   = b ? :always : :never }
          o.on(                  '--[no-]confirm',   'Auto-answer prompts')     { |b| conf['confirm'] = b                    }
          o.on(                  '--[no-]deps',      'Resolve dependencies')    { |b| conf['resolve'] = b                    }
          o.on(                  '--[no-]edit',      'Edit PKGBUILDs')          { |b| conf['edit']    = b ? :always : :never }
          o.separator ''
          o.on(                  '--version',        'Show version')            { puts "raury #{VERSION}"; exit }
          o.on(                  '--debug',          'Show debug output')       { conf['debug'] = true }
          o.separator ''
          o.on(            '-h', '--help',           'Display this screen')     { puts o; exit }
          o.separator ''
          o.separator 'These options can be passed to makepkg:'
          o.separator ''
          mopt(o, conf,    '-c', '--clean',         'Clean up work files after build')
          mopt(o, conf,    '-f', '--force',         'Overwrite existing package')
          mopt(o, conf,    '-L', '--log',           'Log package build process')
          mopt(o, conf,    '-r', '--rmdeps',        'Remove installed dependencies after a successful build')
          mopt(o, conf,          '--asroot',        'Allow makepkg to run as root user')
          mopt(o, conf,          '--sign',          'Sign the resulting package with gpg')
          mopt(o, conf,          '--skipinteg',     'Do not perform any verification checks on source files')
          o.separator ''

        end.parse!(argv)

        [command, argv]

      rescue OptionParser::InvalidOption
        raise InvalidUsage
      end

      private

      def mopt(o, conf, *args)
        o.on(*args) { conf['makepkg_options'] << args.first }
      end

    end
  end
end
