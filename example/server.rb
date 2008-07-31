#!/usr/bin/ruby
require 'rubygems'
require 'socket'
require 'ruby-prof'

port = (ARGV[0] || 80).to_i
server = TCPServer.new('localhost', port)

# Hack require to force reload
alias :old_require :require
def require(file)
  begin
    load(File.dirname(__FILE__) + "/../#{file}.rb") 
  rescue Exception => e
    old_require(file)
  end
end

$output = []
def log(s) $output << s ;end

puts 'Listening to request'

context = {:page => { 
              :title => 'this is a title',
              :description => 'page description', 
              :body=>'page body' 
            },
            :links => ["http://google.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com", "http://yahoo.com"]
}

# Main accept loop
while session = server.accept
  puts "Request: #{session.gets}"
  session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
  require 'h2o'

  Thread.start do
    s = session
    begin
      template = output = nil
      

      10.times { template = H2o::Template.new('inherit.html') }

      RubyProf.start
        output = template.render(context)
      result = RubyProf.stop
      
      
      s.print output
      puts template.context.count
      
      
      # Print a graph profile to text
      printer = RubyProf::GraphHtmlPrinter.new(result)
      File.open('request.html', 'w') do |file|
        printer.print(file, {:min_percent => 1,
                           :print_file => true})
      end
      
      printer = RubyProf::CallTreePrinter.new(result)
      File.open('cachegrind.out.1', 'w') do |file|
        printer.print(file, {:min_percent => 1,
                             :print_file => true})
      end


      s.print "#{Time.now}\r\n"
      s.print "#{$output.join(',')}"
      
    rescue Exception => e
      filter = H2o::Filters[:escape]
      s.print "<pre>Error: " + filter,call(e.inspect) + "</pre>"
      s.print "<pre>stack: " + filter.call(e.backtrace.join("\n")) + "</pre>"
      puts e
    ensure
      s.close
      $output = []
    end
  end
end
