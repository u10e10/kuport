# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kuport/version'

Gem::Specification.new do |spec|
  spec.name          = 'kuport'
  spec.version       = Kuport::VERSION
  spec.authors       = ['u+']
  spec.email         = ['uplus.e10@gmail.com']

  spec.summary       = %q{Kuport scraping library and command}
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/u10e10/kuport'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}){|f| File.basename(f)}
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'mechanize'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
end
