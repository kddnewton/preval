# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'preval/version'

Gem::Specification.new do |spec|
  spec.name          = 'preval'
  spec.version       = Preval::VERSION
  spec.authors       = ['Kevin Newton']
  spec.email         = ['kddnewton@gmail.com']

  spec.summary       = 'Automatically optimizes your Ruby code'
  spec.homepage      = 'https://github.com/kddnewton/preval'
  spec.license       = 'MIT'

  spec.files         =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{^(test|spec|features)/})
      end
    end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
end
