# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fast_output_buffer/version'

Gem::Specification.new do |spec|
  spec.name          = "fast_output_buffer"
  spec.version       = FastSafeBuffer::VERSION
  spec.authors       = ["macournoyer"]
  spec.email         = ["macournoyer@gmail.com"]
  spec.description   = 
  spec.summary       = "Make ActiveSupport::SafeBuffer fast as hell, twice."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extensions    = ["ext/fast_output_buffer_ext/extconf.rb"]

  spec.add_dependency "rails", "~> 4.0.0"

  spec.add_development_dependency 'rake-compiler', '>= 0.8.3'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
