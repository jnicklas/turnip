# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "turnip/version"

Gem::Specification.new do |s|
  s.name        = "turnip"
  s.version     = Turnip::VERSION
  s.authors     = ["Jonas Nicklas"]
  s.email       = ["jonas.nicklas@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Gherkin extension for RSpec}
  s.description = %q{Provides the ability to define steps and run Gherkin files from with RSpec}

  s.rubyforge_project = "turnip"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rspec", [">=2.14.0", "<4.0"]
  s.add_runtime_dependency "gherkin", ">= 2.5"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
