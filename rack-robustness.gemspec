# We require your library, mainly to have access to the VERSION number.
# Feel free to set $version manually.
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require "rack/robustness"
$version = Rack::Robustness::VERSION.dup.to_s

#
# This is your Gem specification. Default values are provided so that your library
# should be correctly packaged given what you have described in the .noespec file.
#
Gem::Specification.new do |s|

  ################################################################### ABOUT YOUR GEM

  # Gem name (required)
  s.name = "rack-robustness"

  # Gem version (required)
  s.version = $version

  # A short summary of this gem
  #
  # This is displayed in `gem list -d`.
  s.summary = "Rack::Robustness, the rescue clause of your Rack stack."

  # A long description of this gem (required)
  #
  # The description should be more detailed than the summary.  For example,
  # you might wish to copy the entire README into the description.
  s.description = "Rack::Robustness provides you with an easy way to handle errors in your stack, for making web applications more robust."

  # The URL of this gem home page (optional)
  s.homepage = "https://github.com/blambeau/rack-robustness"

  # Gem publication date (required but auto)
  #
  # Today is automatically used by default, uncomment only if
  # you know what you do!
  #
  # s.date = Time.now.strftime('%Y-%m-%d')

  # The license(s) for the library.  Each license must be a short name, no
  # more than 64 characters.
  #
  # s.licences = %w{}

  # The rubyforge project this gem lives under (optional)
  #
  # s.rubyforge_project = nil

  ################################################################### ABOUT THE AUTHORS

  # The list of author names who wrote this gem.
  #
  # If you are providing multiple authors and multiple emails they should be
  # in the same order.
  #
  s.authors = ["Bernard Lambeau"]

  # Contact emails for this gem
  #
  # If you are providing multiple authors and multiple emails they should be
  # in the same order.
  #
  # NOTE: Somewhat strangly this attribute is always singular!
  #       Don't replace by s.emails = ...
  s.email  = ["blambeau@gmail.com"]

  ################################################################### PATHS, FILES, BINARIES

  # Paths in the gem to add to $LOAD_PATH when this gem is
  # activated (required).
  #
  # The default 'lib' is typically sufficient.
  s.require_paths = ["lib"]

  # Files included in this gem.
  #
  # By default, we take all files included in the Manifest.txt file on root
  # of the project. Entries of the manifest are interpreted as Dir[...]
  # patterns so that lazy people may use wilcards like lib/**/*
  #
  here = File.expand_path(File.dirname(__FILE__))
  s.files = File.readlines(File.join(here, 'Manifest.txt')).
                 inject([]){|files, pattern| files + Dir[File.join(here, pattern.strip)]}.
                 collect{|x| x[(1+here.size)..-1]}

  # Test files included in this gem.
  #
  s.test_files = Dir["test/**/*"] + Dir["spec/**/*"]

  # The path in the gem for executable scripts (optional)
  #
  s.bindir = "bin"

  # Executables included in the gem.
  #
  s.executables = (Dir["bin/*"]).collect{|f| File.basename(f)}

  ################################################################### REQUIREMENTS & INSTALL
  # Remember the gem version requirements operators and schemes:
  #   =  Equals version
  #   != Not equal to version
  #   >  Greater than version
  #   <  Less than version
  #   >= Greater than or equal to
  #   <= Less than or equal to
  #   ~> Approximately greater than
  #
  # Don't forget to have a look at http://lmgtfy.com/?q=Ruby+Versioning+Policies
  # for setting your gem version.
  #
  # For your requirements to other gems, remember that
  #   ">= 2.2.0"              (optimistic:  specify minimal version)
  #   ">= 2.2.0", "< 3.0"     (pessimistic: not greater than the next major)
  #   "~> 2.2"                (shortcut for ">= 2.2.0", "< 3.0")
  #   "~> 2.2.0"              (shortcut for ">= 2.2.0", "< 2.3.0")
  #

  #
  # One call to add_dependency('gem_name', 'gem version requirement') for each
  # runtime dependency. These gems will be installed with your gem.
  # One call to add_development_dependency('gem_name', 'gem version requirement')
  # for each development dependency. These gems are required for developers
  #
  s.add_development_dependency("rake", "~> 10.0")
  s.add_development_dependency("rspec", "~> 2.12")
  s.add_development_dependency("rack", "~> 1.5")
  s.add_development_dependency("rack-test", "~> 0.6")
  

  # The version of ruby required by this gem
  #
  # Uncomment and set this if your gem requires specific ruby versions.
  #
  # s.required_ruby_version = ">= 0"

  # The RubyGems version required by this gem
  #
  # s.required_rubygems_version = ">= 0"

  # The platform this gem runs on.  See Gem::Platform for details.
  #
  # s.platform = nil

  # Extensions to build when installing the gem.
  #
  # Valid types of extensions are extconf.rb files, configure scripts
  # and rakefiles or mkrf_conf files.
  #
  s.extensions = []

  # External (to RubyGems) requirements that must be met for this gem to work.
  # It’s simply information for the user.
  #
  s.requirements = nil

  # A message that gets displayed after the gem is installed
  #
  # Uncomment and set this if you want to say something to the user
  # after gem installation
  #
  s.post_install_message = nil

  ################################################################### SECURITY

  # The key used to sign this gem.  See Gem::Security for details.
  #
  # s.signing_key = nil

  # The certificate chain used to sign this gem.  See Gem::Security for
  # details.
  #
  # s.cert_chain = []

  ################################################################### RDOC

  # An ARGV style array of options to RDoc
  #
  # See 'rdoc --help' about this
  #
  s.rdoc_options = []

  # Extra files to add to RDoc such as README
  #
  s.extra_rdoc_files = Dir["README.md"] + Dir["CHANGELOG.md"] + Dir["LICENCE.md"]

end
