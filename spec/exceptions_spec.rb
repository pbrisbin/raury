require 'spec_helper'

module Raury
  describe "Errors" do
    def error_should_read(error, msg)
      begin
        raise error
      rescue Exception => ex
        ex.to_s.should == msg
      end
    end

    it "has invalid usage error" do
      error_should_read(InvalidUsage, 'invalid usage. try -h or --help.')
    end

    it "has no targets error" do
      error_should_read(NoTargets, 'No targets provided.')
    end

    it "has network error" do
      error_should_read(NetworkError.new("Exception"), 'Network exception: Exception')
    end

    it "has unkown network error" do
      error_should_read(NetworkError, 'Network exception: <unknown>')
    end

    it "has pkg error" do
      error_should_read(PkgError.new('pkg'), 'pkg: error processing.')
    end

    it "has no results error" do
      error_should_read(NoResults.new('pkg'), 'pkg: target not found.')
    end

    it "has no pkgbuild error" do
      error_should_read(NoPkgbuild.new('pkg'), 'pkg: PKGBUILD not found.')
    end

    it "has edit error error" do
      error_should_read(EditError.new('pkg'), 'pkg: your editor returned non-zero. aborting.')
    end

    it "has build error error" do
      error_should_read(BuildError.new('pkg'), 'pkg: failure while building.')
    end
  end
end
