$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rack/robustness/version'

Gem::Specification.new do |s|
  s.name        = "rack-robustness"
  s.version     = Rack::Robustness::VERSION
  s.summary     = "Rack::Robustness, the rescue clause of your Rack stack."
  s.description = "Rack::Robustness provides you with an easy way to handle errors in your stack, for making web applications more robust."
  s.homepage    = "https://github.com/blambeau/rack-robustness"
  s.authors     = ["Bernard Lambeau"]
  s.email       = ["blambeau@gmail.com"]
  s.license     = "MIT"

  s.files = Dir[
    'lib/**/*',
    'spec/**/*',
    'tasks/**/*',
    'CHANGELOG.md',
    'Gemfile',
    'LICENCE.md',
    'Rakefile',
    'README.md'
  ]
  s.require_paths = ["lib"]
  s.extra_rdoc_files = Dir["README.md"] + Dir["CHANGELOG.md"] + Dir["LICENCE.md"]

  s.metadata = {
    "homepage_uri"    => s.homepage,
    "source_code_uri" => s.homepage,
    "changelog_uri"   => "#{s.homepage}/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "#{s.homepage}/issues"
  }

  s.required_ruby_version = ">= 3.2"
  s.add_runtime_dependency "rack", [">= 3.0", "< 4.0"]

  s.add_development_dependency "rack-test", [">= 2.0", "< 3.0"]
  s.add_development_dependency "rake", [">= 13.0", "< 14.0"]
  s.add_development_dependency "rspec", [">= 3.12", "< 4.0"]
end
