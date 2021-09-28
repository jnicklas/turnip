# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "turnip/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.3"
  s.name        = "turnip"
  s.version     = Turnip::VERSION
  s.authors     = ["Jonas Nicklas"]
  s.email       = ["jonas.nicklas@gmail.com"]
  s.homepage    = "https://github.com/jnicklas/turnip/"
  s.license     = "MIT"
  s.summary     = %q{Gherkin extension for RSpec}
  s.description = %q{Provides the ability to define steps and run Gherkin files from with RSpec}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rspec", [">=3.0", "<4.0"]
  s.add_runtime_dependency "cucumber-gherkin", "~> 22.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"
end
