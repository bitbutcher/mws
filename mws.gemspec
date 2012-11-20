# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mws'

Gem::Specification.new do |gem|
  gem.name          = "mws"
  gem.version       = Mws::VERSION
  gem.authors       = ['Sean M. Duncan', 'John E. Bailey']
  gem.email         = ['info@devmode.com']
  gem.description   = %q{The missing ruby client library for Amazon MWS}
  gem.summary       = %q{The missing ruby client library for Amazon MWS}
  gem.homepage      = 'http://github.com/devmode/mws'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|specs?|feat(ures?)?)/})
  gem.require_paths = ['lib']
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'activesupport'
  gem.add_dependency 'nokogiri'
end
