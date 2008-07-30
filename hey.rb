require 'socket'

port = (ARGV[0] || 80).to_i
server = TCPServer.new('localhost', port)

$output = []
class BufStdout
    def write(s)
        $output << s
    end
end

def log(s)
    $output << s
end

loop do
    session = server.accept
    request = session.gets
    begin
      session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
      load 'h2o.rb'

      template = H2o::Template.new('./inherit.html')
      
      session.print template.render({
        'page' => { 
          'title' => 'this is a title',
          'description' => 'page description', 
          'body' =>'page body' 
        },
        'links' => ["http://google.com", "http://yahoo.com"]
      })
      
      session.print "#{Time.now}\r\n"
      session.print "#{$output.join(',')}"
      
    rescue Exception => e
      filter = H2o::Filters[:escape]
      session.print "<pre>Error: " + filter.call(e.inspect) + "</pre>"
      session.print "<pre><code>stack: " + H2o::Filters[:escape].call(e.backtrace.join("\n")) + "</code></pre>"
    end
      
    session.close
    $output = []
end
