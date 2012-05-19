module Raury
  module Prompt
    def prompt(msg, default = true)
      puts ''
      print "#{msg}? "
      print "#{default ? '[Y/n]' : '[y/N]'} "

      ans = $stdin.gets.strip

      return default if !ans || ans == ''

      ans =~ /^y(es)?/i
    end
  end
end
