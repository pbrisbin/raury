require 'fileutils'
require 'bundler/gem_tasks'
require 'rdoc/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern    = "./spec/**/*_spec.rb"
  t.rspec_opts = '-c'
  t.verbose    = false
end

Rake::RDocTask.new do |rd|
  rd.title = 'Raury'
  rd.rdoc_dir = './doc'
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
end

task :default => :spec
