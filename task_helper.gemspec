# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'task_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "task_helper"
  spec.version       = TaskHelper::VERSION
  spec.authors       = ["JC Wilcox"]
  spec.email         = ["84jwilcox@gmail.com"]
  spec.summary       = %q{Ruby wrapper for the MyTaskHelper.com API}
  spec.description   = %q{Offers a clean Ruby interface for interacting with select MyTaskHelper resources.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'sinatra', '~> 1.4'
  spec.add_development_dependency 'webmock', '~> 1.19'
  spec.add_runtime_dependency     'httparty', '~> 0.13'
end
