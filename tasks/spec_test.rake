# Installs a rake task for for running examples written using rspec.
#
# This file installs the 'rake spec_test' (aliased as 'rake spec') as well as
# extends 'rake test' to run spec tests, if any. It is automatically generated
# by Noe from your .noespec file, and should therefore be configured there,
# under the variables/rake_tasks/spec_test entry, as illustrated below:
#
# variables:
#   rake_tasks:
#     spec_test:
#       pattern: spec/**/*_spec.rb
#       verbose: true
#       rspec_opts: [--color, --backtrace]
#       ...
#
# If you have specific needs requiring manual intervention on this file,
# don't forget to set safe-override to false in your noe specification:
#
# template-info:
#   manifest:
#     tasks/spec_test.rake:
#       safe-override: false
#
# This file has been written to conform to RSpec v2.4.0. More information about
# rspec and options of the rake task defined below can be found on
# http://relishapp.com/rspec
#
begin
  require "rspec/core/rake_task"
  desc "Run RSpec code examples"
  RSpec::Core::RakeTask.new(:spec_test) do |t|
    # Glob pattern to match files.
    t.pattern = "spec/**/test_*.rb"

    # Whether or not to fail Rake when an error occurs (typically when
    # examples fail).
    t.fail_on_error = true

    # A message to print to stderr when there are failures.
    t.failure_message = nil

    # Use verbose output. If this is set to true, the task will print the
    # executed spec command to stdout.
    t.verbose = true

    # Use rcov for code coverage?
    t.rcov = false

    # Path to rcov.
    t.rcov_path = "rcov"

    # Command line options to pass to rcov. See 'rcov --help' about this
    t.rcov_opts = []

    # Command line options to pass to ruby. See 'ruby --help' about this
    t.ruby_opts = []

    # Path to rspec
    t.rspec_path = "rspec"

    # Command line options to pass to rspec. See 'rspec --help' about this
    t.rspec_opts = ["--color", "--backtrace"]
  end
rescue LoadError => ex
  task :spec_test do
    abort 'rspec is not available. In order to run spec, you must: gem install rspec'
  end
ensure
  task :spec => [:spec_test]
  task :test => [:spec_test]
end
