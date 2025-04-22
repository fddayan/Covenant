# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'covenant/version'

Gem::Specification.new do |spec|
  spec.name = 'covenant'
  spec.version       = Covenant::VERSION
  spec.authors       = ['Your Name']
  spec.email         = ['your.email@example.com']

  spec.summary       = 'Covenant gem'
  spec.description   = 'design-by-contract, schema-first, defensive-programming, type-driven-design'
  spec.homepage      = 'https://github.com/fddayan/covenant'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1.0'

  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
