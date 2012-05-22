require 'paint'

module Raury
  module Output
    COLOR_METHODS = [ :white,
                      :magenta,
                      :green,
                      :red,
                      :cyan,
                      :yellow,
                      :black ]

    Paint::SHORTCUTS[:raury] = {}.tap do |hsh|
      COLOR_METHODS.each do |c|
        hsh[c] = Paint.color(c, :bright)
      end
    end

    def self.included(base)
      COLOR_METHODS.each do |c|
        base.class_eval %{
          def #{c}(str)
            if Config.color?
              Paint::Raury.#{c}(str)
            else
              str
            end
          end
        }
      end
    end

    def debug(msg)
      return unless Config.debug?

      divider = black('-' * 80)

      puts '', divider
      puts black(msg)
      puts divider, ''
    end

    def warn(msg)
      $stderr.puts "#{yellow 'warning:'} #{msg}"
    end

    def error(msg)
      $stderr.puts "#{red 'error:'} #{msg}"
    end
  end
end
