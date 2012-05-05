module Raury
  class InvalidUsage < StandardError

  end

  class NetworkError < StandardError

  end

  class NoResults < StandardError

  end

  class SubClassNotImplemented < StandardError

  end

  class NoPkgbuild < StandardError

  end

  class BuildError < StandardError

  end
end
