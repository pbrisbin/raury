module Raury
  class InvalidUsage < StandardError
    def to_s
      'invalid usage. try -h or --help.'
    end
  end

  class NetworkError < StandardError
    def intialize(ex = nil)
      @ex = ex
    end

    def to_s
      "Network exception #{@ex ? @ex.to_s : '<unknown>'}"
    end
  end

  class NoTargets < StandardError
    def to_s
      'No targets provided.'
    end
  end

  class PkgError < StandardError
    def initialize(pkg)
      @pkg = pkg
    end

    # subclass should override
    def msg
      'error processing'
    end

    def to_s
      "#{@pkg}: #{msg}."
    end
  end

  class NoResults < PkgError
    def msg
      'target not found'
    end
  end

  class NoPkgbuild < PkgError
    def msg
      'PKGBUILD not found'
    end
  end

  class EditError < PkgError
    def msg
      'your editor returned non-zero. aborting.'
    end
  end

  class BuildError < PkgError
    def msg
      'failure while building'
    end
  end
end
