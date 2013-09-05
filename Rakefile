require "bundler/gem_tasks"
require "rake/extensiontask"
require 'rake/testtask'

Rake::ExtensionTask.new("fast_output_buffer_ext")

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**_test.rb'
end

task :default => :test
