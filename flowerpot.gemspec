# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flowerpot/version'

Gem::Specification.new do |spec|
  spec.name          = "flowerpot"
  spec.version       = Flowerpot::VERSION
  spec.authors       = ["bytemine GmbH"]
  spec.email         = ["support@bytemine.net"]
  spec.homepage      = "https://github.com/bytemine/flowerpot"

  spec.summary       = "Flowerpot is a wrapper for various messaging channels."
  spec.description   = "Flowerpot is a wrapper for various messaging channels. Currently Telegram, CM Telecom and Twilio are supported."

  spec.files         = Dir.glob("{bin,lib}/**/*")

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_dependency "twilio-ruby"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
