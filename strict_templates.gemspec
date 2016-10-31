# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'strict_templates/version'

Gem::Specification.new do |spec|
  spec.name          = "strict_templates"
  spec.version       = StrictTemplates::VERSION
  spec.authors       = ["Kelly Sutton"]
  spec.email         = ["michael.k.sutton@gmail.com"]

  spec.summary       = %q{Prevent database calls in your templates.}
  spec.description   = %q{Prevent database calls in your templates. }
  spec.homepage      = "https://github.com/kellysutton/strict_templates"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
