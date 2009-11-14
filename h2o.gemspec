Gem::Specification.new do |s|
  s.name     = "h2o"
  s.version  = "0.2"
  s.date     = "2008-09-5"
  s.summary  = "Django inspired template markup"
  s.email    = "taylor.luk@idealian.net"
  s.homepage = "http://github.com/speedmax/h2o"
  s.description = "h2o is a django inspired template that offers natural template syntax and easy to integrate."
  s.has_rdoc = true
  s.authors  = ["Taylor Luk"]
  s.files    = ["README.md", 
		"h2o.gemspec", 
		"lib/h2o.rb", 
		"lib/h2o/", 
		"lib/h2o/constants.rb", 
		"lib/h2o/context.rb", 
		"lib/h2o/datatype.rb", 
		"lib/h2o/errors.rb", 
		"lib/h2o/filters.rb", 
		"lib/h2o/nodes.rb", 
		"lib/h2o/parser.rb", 
		"lib/h2o/tags.rb", 
		"lib/h2o/tags/block.rb", 
		"lib/h2o/tags/for.rb", 
		"lib/h2o/tags/if.rb", 
		"lib/h2o/tags/with.rb",
		"example/server.rb",
		"example/run.rb",
		"example/server",
		"example/server.bat",
		"example/request.html",
		"example/erb/base.html",
		"example/h2o/base.html",
		"example/h2o/inherit.html",
		"example/liquid/base.html",
		]
  s.test_files = []
  s.rdoc_options = ["--main", "README.md"]
  s.extra_rdoc_files = ["README.md"]
end
