# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hallon-fifo/version'

Gem::Specification.new do |gem|
  gem.name          = "hallon-fifo"
  gem.version       = Hallon::Fifo::VERSION
  gem.authors       = ["Elliott Williams"]
  gem.email         = ["e@elliottwillia.ms"]
  gem.description   = "An audio driver for Hallon, a ruby client for the official " +
    "Spotify API. Streams audio into a raw PCM-formatted FIFO queue, ideal for " +
    "input into other applications."
  gem.summary       = "Stream Spotify through Hallon to a FIFO queue."
  gem.homepage      = "http://github.com/elliottwilliams/hallon-fifo"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "mkfifo"
end
