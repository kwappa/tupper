# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tupper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["SHIOYA, Hiromu"]
  gem.email         = ["kwappa.856@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tupper"
  gem.require_paths = ["lib"]
  gem.version       = Tupper::VERSION
end
