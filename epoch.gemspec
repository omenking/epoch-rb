# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epoch/version'

Gem::Specification.new do |spec|
  spec.name          = 'epoch-rb'
  spec.version       = Epoch::VERSION
  spec.authors       = ['Monsterbox Productions']
  spec.email         = ['info@monsterboxpro.com']
  spec.description   = %q{Ruby library to interact with 3poch}
  spec.summary       = %q{Ruby library to interact with 3poch}
  spec.homepage      = 'https://github.com/omenking/epoch-rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rr'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rdoc', '> 2.4.2'
end
