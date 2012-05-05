require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern    = "./spec/**/*_spec.rb"
  t.rspec_opts = '-c'
  t.verbose    = false
end

# integration tests run real commands, actually hit the AUR and describe
# the expected stdout. they're not guaranteed to always pass since the
# search results might change over time.
desc 'run the integration tests'
task :integration do
  system('rspec -c ./spec/*_integration.rb')
end

task :default => :spec
