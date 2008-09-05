require 'rubygems'
require 'server'
require 'benchmark'

# Hack require to force reload
alias :old_require :require
def require file
  begin; load(File.dirname(__FILE__) + "/../lib/#{file}.rb");rescue Exception => e;old_require(file);end
end

def profile mode
  raise "please give me a block" unless block_given?
  require 'ruby-prof' unless defined?(RubyProf)
  
  modes = {
    :memory => RubyProf::MEMORY ,
    :cpu => RubyProf::CPU_TIME ,
    :time => RubyProf::WALL_TIME, 
    :allocation => RubyProf::ALLOCATIONS 
  }
  
  RubyProf.measure_mode if mode = modes[mode]
  
  begin
    RubyProf.start
      yield
  ensure
    result =  RubyProf.stop
  end

  # Print a graph profile to text
  
  printer = RubyProf::FlatPrinter.new(result)
  File.open('request.html', 'w') do |file|
    printer.print(STDOUT, {:min_percent => 1, :print_file => true})
  end
  
  printer = RubyProf::CallTreePrinter.new(result)
  File.open('cachegrind.out.1', 'w') do |file|
    printer.print(file, {:min_percent => 1, :print_file => true})
  end
end

# Context
context = {
  'page' => { 
    'title' => 'this is a title',
    'description' => 'page description', 
    'body' =>'page body' 
  },
  #:callable => Proc.new { "my ass"; a = 2/0 },
  'links' => ["http://google.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com"]
}

# require 'liquid'
# require 'pathname'
# require 'erb'
# 
# class ErbTemplate 
#   def initialize(file)
#     @template = ERB.new(Pathname.new(file).read)
#   end
# 
#   def render context
#     @template.result binding
#   end
# end


address= "localhost:#{(ARGV[0]||80)}"

# Start server and run template
Server.start address do |s|  
  require 'h2o'


  h2o = H2o::Template.new('h2o/inherit.html')
  # liquid  = Liquid::Template.parse(Pathname.new('liquid/base.html').read)
  # erb = ErbTemplate.new('erb/base.html')
  # 
   Benchmark.bm do|b|
     
       b.report('H2o time :') { s.print h2o.render(context) }
#     
#       s.print 'liquid rendering result<hr>'
#       b.report("Liquid time :") { s.print liquid.render(context) }
#       
#       s.print 'erb rendering result<hr>'
#       b.report("erb time :") { s.print erb.render(context) }
   end

#    profile :memory do
#      s.print h2o.render(context)
#    end
end

