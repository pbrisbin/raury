module Raury
  # Downloads taurballs for search results.
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
      write_to(File.open(target, 'w'))
    end

    # downloads the taurball directly to tar, extracting it in the
    # current directory
    def extract
      debug("downloading #{@pkg_url} => tar fxz -")
      write_to(IO.popen('tar fxz -', 'w'))
    end

    private

    def write_to(handle)
      handle.write(@aur.fetch)
    ensure
      handle.close
    end
  end
end
