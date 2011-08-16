require 'rubygems'
require 'rake'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = "./spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new(:coverage) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'spec']
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "SgfParser #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Manage gem versioning since Bundler doesn't do it"
namespace 'version' do
  desc "Bump major version number"
  task "bump:major" do
    #TODO implement bump:major
  end
  desc "Bump minor version number"
  task "bump:minor" do
    #TODO implement bump:minor
  end
  desc "Bump patch version number"
  task "bump:patch" do
    #TODO implement bump:patch
  end
  desc "write out a specified version"
  task "write" do
    #TODO implement write
  end
end
