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

namespace :rdoc do
  desc "publish rdocs to my server"
  task :publish => [:rdoc] do
    pub = File.expand_path('~/Code/haskell/devsite/static/docs/ruby/raury')

    FileUtils.rm_rf pub, :verbose => true
    FileUtils.cp_r 'doc', pub, :verbose => true
  end
end

task :default => :spec
