# Raury

Yet another simple aur helper. This one's in ruby.

## Performance

~~~ 
Searching for "python":

  aurget  0.84s user 0.26s system 41% cpu 2.660 total
  raury   0.37s user 0.05s system 23% cpu 1.754 total

Recursively resolving the dependencies for haskell-yesod:

  aurget  7.40s user  3.44s system 16% cpu 1:03.92  total
  raury   8.20s user 12.62s system 63% cpu   33.027 total

Checking for available upgrades:

  aurget  1.30s user 0.61s system 13% cpu 14.378 total
  raury   0.66s user 0.08s system 40% cpu  1.836 total
~~~

## Running specs

~~~ 
$ rake
~~~

## Try it

~~~ 
$ ruby -Ilib bin/raury --help
~~~

## Installation

~~~ 
$ gem install bundler
$ rake install
$ raury --help
~~~

## Project state

Done:

1. Search/Info
2. Download/Extract/Build/Install
3. Process available upgrades
4. Resolve dependencies
5. Edit PKGBUILDs before building
6. Config file and commandline options

Planned:

1. Keep/discard build files
2. Handle "development" packages specially
3. Custom makepkg options
4. `--asroot`
5. `--rebuild`
6. `--[no-]color`
7. `--[no-]confirm`
