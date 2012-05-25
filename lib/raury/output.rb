require 'paint'

module Raury
  # Handles optional coloring and centralized output functions.
  module Output
    # colors we support
    COLORS = [ :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white ]

    # when included, define a method for each color which colorizes the
    # string (or not) depending on the color setting.
    def self.included(base)
      COLORS.each do |c|
        base.class_eval %{
          def #{c}(str)
            if Config.color?
              Paint[str, #{c.inspect}, :bright]
            else
              str
            end
          end
        }
      end
    end

    # output dividers before and after yielding to the block. note: not
    # threadsafe.
    def debug_box(&block)
      return unless Config.debug?

      debug("\n" + '-' * 80)
      yield
      debug('-' * 80 + "\n")
    end

    def debug(msg)
      $stderr.print "#{black msg}\n" if Config.debug?
    end

    def warn(msg)
      $stderr.print "#{yellow 'warning:'} #{msg}\n"
    end

    def error(msg)
      $stderr.print "#{red 'error:'} #{msg}\n"
    end
  end
end
