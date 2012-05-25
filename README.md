# Raury

Yet another simple aur helper. This one's in ruby.

## Why?

~~~ 
Recursively resolving the (83) dependencies for haskell-yesod:

  2.70s user 3.27s system 160% cpu 3.710 total

Checking for available upgrades to my (54) foreign packages:

  0.61s user 0.08s system 38% cpu 1.787 total

~~~

## Dependencies

~~~ 
$ gem install bundler
$ bundle install
~~~

## Installation

~~~ 
$ rake install
~~~

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

## Running Specs

~~~ 
$ rake
~~~

## Viewing Docs

~~~ 
$ rake rdoc
$ $BROWSER ./doc/index.html
~~~

Also available [here](http://pbrisbin.com/static/docs/ruby/raury/).
