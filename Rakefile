require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
	s.name = "patheditor"
	s.summary = "A simple program to manage the Windows PATH environment variable."
	s.version = "1.1.0"
	s.author = "Justin Bailey"
	s.email = "jgbailey@nospam@gmail.com"
	s.homepage = "http://rubyforge.org/projects/patheditor/"
	s.rubyforge_project = "http://rubyforge.org/projects/patheditor/"
	
	s.description = <<EOS
This gem provides an application, path_editor, which makes it easy to add, remove, display or clean up the
Windows System and User PATH variables. Note this does NOT any transient variables active in the current process -
it only affects those which are stored in the registry and set before each process begins. It's a nice
alternative to using "Computer / Properties / Advanced" for updating environment variables.
EOS

	s.platform = Gem::Platform::CURRENT
	s.files = FileList["lib/**/*", "test/**/*", "*.txt", "Rakefile"].to_a

	s.bindir = "bin"
	s.executables = ["path_editor"]
	s.require_path = "lib"

	s.has_rdoc = true
	s.extra_rdoc_files = ["README.txt"]
	s.rdoc_options << '--title' << 'PathEditor -- A PATH environment variable editor' <<
                       '--main' << 'README.txt' <<
                       '--line-numbers'

	s.add_dependency("highline", ">= 1.2.3")
	s.add_dependency("commandline", ">= 0.7.10")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
