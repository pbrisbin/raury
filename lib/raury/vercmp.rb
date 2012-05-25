module Raury
  # An accurate port of pacman's vercmp.c
  class Vercmp
    include Comparable

    SEP = /[^a-z0-9]/i

    attr_reader :epoch, :version, :release

    def initialize(s)
      str = s.to_s.dup.strip

      if str =~ /([^:]+)?:(.*?)(-([^-]+))?$/
        # with epoch
        @epoch, @version, @release = $1, $2, $4

      elsif str =~ /(.*?)(-([^-]+))?$/
        # without epoch
        @epoch, @version, @release = '0', $1, $3
      end
    end

    def <=>(other)
      ret = vercmp(epoch, other.epoch)
      return ret unless ret == 0

      ret = vercmp(version, other.version)
      return ret unless ret == 0 && release && other.release

      vercmp(release, other.release)
    end

    private

    def vercmp(a, b)
      return 0 if a == b

      segments_a = a.split(SEP)
      segments_b = b.split(SEP)

      loop do
        seg_a = segments_a.shift
        seg_b = segments_b.shift

        if !(seg_a && seg_b)
          return  1 if seg_a
          return -1 if seg_b
          return  0
        end

        if !(numeric?(seg_a) && numeric?(seg_b))
          return  1 if numeric?(seg_a)
          return -1 if numeric?(seg_b)

          if !(blank?(seg_a) && blank?(seg_b))
            return  1 if blank?(seg_a)
            return -1 if blank?(seg_b)
          end

          ret = seg_a <=> seg_b
          return ret unless ret == 0
        else
          ret = seg_a.to_i <=> seg_b.to_i
          return ret unless ret == 0
        end
      end
    end

    def numeric?(n)
      n.to_i.to_s == n
    end

    def blank?(str)
      str.strip == ''
    end
  end
end
