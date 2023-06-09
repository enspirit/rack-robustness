namespace :test do
  require 'rspec/core/rake_task'

  desc %q{Run all RSpec tests}
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = %w[-I. -Ilib -Ispec --pattern=spec/**/test_*.rb --color .]
  end

  task :all => :"unit"
end
task :test => :"test:all"
