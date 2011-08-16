# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sgf/version"

Gem::Specification.new do |s|
  s.version     = SGF::VERSION
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "help"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

Gem::Specification.new do |s|
  s.name = %q{SgfParser}
  s.version = SGF::VERSION
  s.authors = ["Aldric Giacomoni"]
  s.email = %q{trevoke@gmail.com}
  s.homepage = %q{http://github.com/Trevoke/SGFParser}
  s.date = %q{2011-08-01}
  s.summary = %q{SgfParser is a library that parses and saves SGF (Smart Game Format) files.}
  s.description = %q{SGF::Parser does standard stream parsing of the SGF file, instead of using an AG or some other auto-generated newfangled parser stuff. It is therefore faster to use, and hopefully will also be easier to use. Feedback helps :)}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rcov'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
end

