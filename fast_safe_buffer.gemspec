# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fast_safe_buffer/version'

Gem::Specification.new do |spec|
  spec.name          = "fast_safe_buffer"
  spec.version       = FastSafeBuffer::VERSION
  spec.authors       = ["macournoyer"]
  spec.email         = ["macournoyer@gmail.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extensions    = ["ext/fast_safe_buffer_ext/extconf.rb"]

  spec.add_dependency 'activesupport', '~> 4.0.0'

  spec.add_development_dependency 'rake-compiler', '>= 0.8.3'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
