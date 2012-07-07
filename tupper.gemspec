# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tupper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["SHIOYA, Hiromu"]
  gem.email         = ["kwappa.856@gmail.com"]
  gem.description   = "Tupper is a helper for processing uploaded file via web form."
  gem.summary       = "Tupper is a helper for processing uploaded file via web form."
  gem.homepage      = "https://github.com/kwappa/tupper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tupper"
  gem.require_paths = ["lib"]
  gem.version       = Tupper::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "fakefs"
end
