require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new do |r|
  r.verbose = false
end

RuboCop::RakeTask.new

task default: [:spec, :rubocop]
