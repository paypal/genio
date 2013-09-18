# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'genio/version'

Gem::Specification.new do |spec|
  spec.name          = "genio"
  spec.version       = Genio::VERSION
  spec.authors       = ["PayPal"]
  spec.email         = ["DL-PP-Platform-Ruby-SDK@ebay.com"]
  spec.description   = %q{Generate SDK}
  spec.summary       = %q{Generate SDK}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["{lib,templates,bin}/**/*"] + [ "README.md", "LICENSE.txt" ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "genio-parser"
  spec.add_dependency "activesupport"
  spec.add_dependency "tilt"
  spec.add_dependency "erubis"
  spec.add_dependency "thor"
  # spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
