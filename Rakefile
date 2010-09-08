begin
  require 'spec/rake/spectask'
rescue LoadError
  puts 'To use rspec for testing you must install rspec gem:'
  puts '$ sudo gem install rspec'
  exit
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "h2o"
    s.summary = "h2o is a django inspired template"
    s.description = "h2o is a django inspired template that offers natural template syntax and easy to integrate."
    s.email = "subjective@gmail.com"
    s.homepage = "http://www.h2o-template.org"
    s.authors = ["Taylor luk"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Default task is to run specs"
task :default => :spec