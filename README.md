# Raury

An aurget-like helper written in ruby.

## Why?

1. Easier to hack on (97% test coverage)
2. Useful debug output (pretty colors!)
3. It's very fast (compared to aurget at least)

## Try it

~~~
$ gem install bundler
$ bundle
$ bundle exec bin/raury --help
~~~

## Install it

~~~
$ curl https://github.com/pbrisbin/raury/raw/master/install.sh | bash
~~~

Arch users can use the PKGBUILD.

## Usage

~~~
usage: raury [command] [options] [arguments]

Commands:
    -S, --sync                       Process packages
    -u, --upgrade                    Upgrade packages
    -s, --search                     Search for packages
    -i, --info                       Show info for packages

Options:
    -d, --download                   Stop after downloading
    -e, --extract                    Stop after extracting
    -b, --build                      Stop after building
    -y, --install                    Install after building

        --build-dir DIR              Set build directory
        --ignore PKG                 Ignore package
        --[no-]color                 Colorize output
        --[no-]confirm               Auto-answer prompts
        --[no-]deps                  Resolve dependencies
        --[no-]edit                  Edit PKGBUILDs
        --[no-]source                Source for dependencies

        --version                    Show version
        --debug                      Show debug output

    -h, --help                       Display this screen

These options can be passed to makepkg:

    -c, --clean                      Clean up work files after build
    -f, --force                      Overwrite existing package
    -L, --log                        Log package build process
    -r, --rmdeps                     Remove installed dependencies after a successful build
        --asroot                     Allow makepkg to run as root user
        --sign                       Sign the resulting package with gpg
        --skipinteg                  Do not perform any verification checks on source files

~~~

## Configuration

For default behavior, please see the `DEFAULTS` hash [here][defaults].

[defaults]: https://github.com/pbrisbin/raury/blob/master/lib/raury/config.rb#L22

Any of these values can be overridden via `$XDG_CONFIG_HOME/rauaryrc` 
(or `$HOME/.rauryrc` if `$XDG_CONFIG_HOME` is not set)

**Example**:

~~~ { .yaml }
# vim: ft=yaml:

build_directory: ~/Sources
resolve:         true
source:          true
edit:            never
keep_devels:     true
makepkg_options: ['-c', '-r']
~~~

## Development

### Specs

~~~
$ rake
~~~

### Docs

~~~
$ rake rdoc
$ $BROWSER ./doc/index.html
~~~

Also available [here](http://docs.pbrisbin.com/ruby/raury/).
