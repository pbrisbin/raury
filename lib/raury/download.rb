module Raury
  class Download
    def initialize(package)
      @pkg_url = Rpc.new(:info, package).call.pkg_url
      @aur     = Aur.new(@pkg_url)
    end

    # downloads the taurball in current directory
    def download
      target = File.basename(@pkg_url)

      File.open(target, 'w') do |fh|
        fh.write(@aur.fetch)
      end
    end

    # downloads the taurball directly to tar, extracting it in the
    # current directory
    def extract
      IO.popen('tar fxz -', 'w') do |h|
        h.write(@aur.fetch)
        h.close_write
      end
    end
  end
end
