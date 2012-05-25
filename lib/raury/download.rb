module Raury
  class Download
    include Output

    def initialize(result)
      @pkg_url = result.pkg_url
      @aur     = Aur.new(@pkg_url)
    end

    # downloads the taurball in current directory
    def download
      target = File.basename(@pkg_url)

      debug("downloading #{@pkg_url} => #{target}")
      File.open(target, 'w') do |fh|
        fh.write(@aur.fetch)
      end
    end

    # downloads the taurball directly to tar, extracting it in the
    # current directory
    def extract
      debug("downloading #{@pkg_url} => tar fxz -")
      IO.popen('tar fxz -', 'w') do |h|
        h.write(@aur.fetch)
        h.close_write
      end
    end
  end
end
