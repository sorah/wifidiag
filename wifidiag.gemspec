# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wifidiag/version'

Gem::Specification.new do |spec|
  spec.name          = "wifidiag"
  spec.version       = Wifidiag::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["her@sorah.jp"]

  spec.summary       = %q{Quick Wi-Fi diagnostic page for users, to support network ops}
  spec.homepage      = "https://github.com/sorah/wifidiag"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "wlc_snmp"
  spec.add_dependency "sinatra"
end
