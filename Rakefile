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

desc "Handle gem version"
namespace 'version' do
  desc "Bump major version number"
  task "bump:major" do
    bump :major
  end
  desc "Bump minor version number"
  task "bump:minor" do
    bump :minor
  end
  desc "Bump patch version number"
  task "bump:patch" do
    bump :patch
  end
  desc "write out a specified version"
  task "write", :version do |task, args|
    change_version_to(args.version)
  end
end

VERSION_ASSIGNMENT_REGEXP = /\A\s*?VERSION\s*?=\s*?['"](.*?)['"]\s*?\z/mx

def raise_too_many_files_found
  raise ArgumentError, "There are two files called version.rb and I do not know which one to use. Override the version_file_name method in your Rakefile and provide the correct path."
end

def raise_too_many_lines_matched
  raise ArgumentError, "There are more than one line in version.rb which assign a value to VERSION. This is almost certainly a mistake. At the very least, I have no idea what I'm supposed to do. You must either increment the version manually in the file, or change the file so it only assigns VERSION once."
end

def raise_no_lines_matched
  raise ArgumentError, "I did not find anything in the version file matching a version assignment."
end

def bump bit_to_increment
  change_version_to incremented_version(bit_to_increment)
end

def change_version_to(new_version_string)
  File.open(version_file_name, 'w') { |f| f << new_version_file_string( new_version_string ) }
  puts "New version is now #{new_version_string}"
end

def incremented_version bit
  version_hash = {}
  version_hash[:major], version_hash[:minor], version_hash[:patch] = current_version.split('.')
  version_hash[bit] = version_hash[bit].to_i + 1
  "#{version_hash[:major]}.#{version_hash[:minor]}.#{version_hash[:patch]}"
end

def new_version_file_string new_version_number
  arrayed_current_version_file.map do |line|
    is_version_line?(line) ? %Q{  VERSION = "#{new_version_number}"\n} : line
  end.join
end

def current_version
  array_of_value_versions = arrayed_current_version_file.grep(VERSION_ASSIGNMENT_REGEXP) { $1 }
  raise_too_many_lines_matched if array_of_value_versions.size > 1
  raise_no_lines_matched if array_of_value_versions.empty?
  array_of_value_versions.first
end

def arrayed_current_version_file
  File.readlines(version_file_name)
end

def version_file_name
  file_array = Dir['*/**/version.rb']
  raise_too_many_files_found if file_array.size > 1
  file_array.first
end

def is_version_line? line
  !!(line[VERSION_ASSIGNMENT_REGEXP])
end