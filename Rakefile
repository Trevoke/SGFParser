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
  task "write" do
    #TODO implement write
  end
end

def bump flag
  version = {}
  version[:major], version[:minor], version[:patch] = current_version.split('.')
  version[flag] = version[flag].to_i + 1
  new_flags = "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
  File.open(version_file, 'w') { |f| f << new_version_file_string(new_flags) }
  puts "New version is now #{new_flags}"
end

def current_version
  @current_version ||= find_current_version
end

def arrayed_current_version_file
  @arrayed_current_version_file ||= File.readlines version_file
end

def version_file
  @version_file ||= determine_version_file
end

def new_version_file_string version_number
  @new_file ||= create_new_version_file_string(version_number)
end

def find_current_version
  version_line_array = arrayed_current_version_file.find_all { |x| is_version_line? x }
  if version_line_array.size > 1
    raise ArgumentError, "There are more than one line in version.rb which assign a value to VERSION. This is almost certainly a mistake. At the very least, I have no idea what I'm supposed to do. You must either increment the version manually in the file, or change the file so it only assigns VERSION once."
  end
  if version_line_array.size < 1
    p arrayed_current_version_file
    raise ArgumentError, "I did not find anything in the version file matching a version assignment."
  end
  version_number version_line_array.first
end

def determine_version_file
  file_array = Dir['*/**/version.rb']
  if file_array.size > 1
    raise ArgumentError, "There are two files called version.rb and I do not know which one to use. Override the version_file method in your Rakefile and provide the correct path."
  end
  file_array.first
end

def create_new_version_file_string(new_version_number)
  new_file = ""
  arrayed_current_version_file.each do |line|
    if is_version_line? line
      new_file << %Q{VERSION = "#{new_version_number}"\n}
    else
      new_file << line
    end
  end
  new_file
end

def is_version_line? line
  !!version_number(line)
end


def version_number line
  line[/\A\s*?VERSION\s*?=\s*?['"](.*?)['"]\s*?\z/mx]
  $1
end