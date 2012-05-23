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
$ bundle install
$ rake
~~~

## Try it

~~~ 
$ bundle install
$ bundle exec bin/raury --help
~~~

## Installation

~~~ 
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
7. Pass-through makepkg options
8. Color
9. Handle "development" packages specially
