# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nrser/version'

Gem::Specification.new do |spec|
  spec.name          = "nrser"
  spec.version       = NRSER::VERSION
  spec.authors       = ["nrser"]
  spec.email         = ["neil@neilsouza.com"]
  spec.summary       = %q{basic ruby utils i use in a lot of stuff.}
  spec.homepage      = "https://github.com/nrser/nrser-ruby"
  spec.license       = "MIT"
  
  spec.required_ruby_version = '>= 2.3.0'

  spec.files         = Dir["lib/**/*.rb"] + %w(LICENSE.txt README.md)
  spec.executables   = [] # spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir["spec/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  
  # Doc gen with `yard`
  spec.add_development_dependency "yard"
  # `yard` will use RDoc's built-in Markdown support, which is pretty GFM-like,
  # but we'll explicitly include `redcarpet` and `github-markup` to make sure
  # we get the functionality we want.
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "github-markup"
  
  spec.add_development_dependency "cmds"
  
  # Better CLI
  spec.add_development_dependency "pry"
end
