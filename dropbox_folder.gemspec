# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dropbox_folder/version"

Gem::Specification.new do |s|
  s.name        = "dropbox_folder"
  s.version     = DropboxFolder::VERSION
  s.authors     = ["Boris Barroso"]
  s.email       = ["boriscyber@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Creates a folder in dropbox for an activerecord model}
  s.description = %q{Creates or updates dropbox model folders}


  s.add_dependency 'activerecord', '>= 3.0.2'
  s.add_dependency 'activesupport', '>= 3.0.2'
  s.add_dependency 'mechanize', '1.0.0'
  s.add_dependency 'dropbox', '1.3.0'
  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.3'

  s.rubyforge_project = "dropboxfolder"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
