require 'paint'

module Raury
  module Output
    COLORS = [ :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white ]

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

    def debug(msg)
      $stderr.print "#{black msg}\n" if Config.debug?
    end

    # note: not threadsafe
    def debug_box(&block)
      return unless Config.debug?

      debug("\n" + '-' * 80)
      yield
      debug('-' * 80 + "\n")
    end

    def warn(msg)
      $stderr.print "#{yellow 'warning:'} #{msg}\n"
    end

    def error(msg)
      $stderr.print "#{red 'error:'} #{msg}\n"
    end
  end
end
