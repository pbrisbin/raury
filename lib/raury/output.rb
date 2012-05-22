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
      $stderr.puts black(msg) if Config.debug?
    end

    def warn(msg)
      $stderr.puts "#{yellow 'warning:'} #{msg}"
    end

    def error(msg)
      $stderr.puts "#{red 'error:'} #{msg}"
    end
  end
end
