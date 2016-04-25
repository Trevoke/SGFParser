# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sgf/version"

Gem::Specification.new do |s|
  s.name = %q{SgfParser}
  s.version = SGF::VERSION
  s.authors = ["Aldric Giacomoni"]
  s.email = %q{trevoke@gmail.com}
  s.homepage = %q{http://github.com/Trevoke/SGFParser}
  s.date = %q{2016-04-24}
  s.summary = %q{A library that parses and saves SGF (Smart Game Format) files.}
  s.description = %q{SGF::Parser does standard stream parsing of the SGF file, instead of using an AG or some other auto-generated parser. It is therefore faster to use. It also intends to be very object-oriented and hopefully will also be easier to use.}
  s.extra_rdoc_files = %w(LICENSE README.md)
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'pry-byebug'
end
