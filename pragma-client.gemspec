# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pragma/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'pragma-client'
  spec.version       = Pragma::Client::VERSION
  spec.authors       = ['Alessandro Desantis']
  spec.email         = ['desa.alessandro@gmail.com']

  spec.summary       = 'A client for interacting with Pragma APIs.'
  spec.homepage      = 'https://github.com/pragmarb/pragma-client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5.1'
  spec.add_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.23'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.3'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end
