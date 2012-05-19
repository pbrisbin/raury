# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "raury/version"

Gem::Specification.new do |s|
  s.name        = "raury"
  s.version     = Raury::VERSION
  s.authors     = ["patrick brisbin"]
  s.email       = ["pbrisbin@gmail.com"]
  s.homepage    = "http://github.com/pbrisbin/raury"
  s.summary     = "aur helper in ruby"
  s.description = "aur helper in ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.licenses      = ["MIT"]
end
