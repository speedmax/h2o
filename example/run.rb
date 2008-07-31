require 'rubygems'
require 'server'
require 'benchmark'

# Hack require to force reload
alias :old_require :require
def require file
  begin; load(File.dirname(__FILE__) + "/../#{file}.rb");rescue Exception => e;old_require(file);end
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
  
  result = RubyProf.profile do
    yield
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
  :page => { 
    :title => 'this is a title',
    :description => 'page description', 
    :body=>'page body' 
  },
  #:callable => Proc.new { "my ass"; a = 2/0 },
  :links => ["http://google.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com"]
}

address= "localhost:#{(ARGV[0]||80)}"

# Start server and run template
Server.start address do |s|  
  require 'h2o'
  template = H2o::Template.new('inherit.html')
  
  Benchmark.bm do|b|
    b.report do
        s.print template.render(context)
    end
  end
  
  # profile :memory do
  #   s.print template.render(context)
  # end
end

