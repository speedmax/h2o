#!/usr/bin/ruby
require 'socket'
require 'benchmark'

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
      
      Benchmark.bm do |b|
        b.report 'Load and parse the template' do
          100.times { template = H2o::Template.new('inherit.html') }
        end
        
        b.report 'Rendering the template against the context' do
          100.times {
            output = template.render(context)
          }
          s.print output
        end
      end    
      s.print "#{Time.now}\r\n"
      s.print "#{$output.join(',')}"
      
    rescue Exception => e
      s.print "<pre>Error: " + e.inspect + "</pre>"
      s.print "<pre>stack: " + e.backtrace.join("\n") + "</pre>"
    ensure
      s.close
      $output = []
    end
  end
end
