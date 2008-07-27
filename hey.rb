require 'socket'

port = (ARGV[0] || 80).to_i
server = TCPServer.new('localhost', port)

$output = []

class BufStdout
    def write(s)
        $output << s
    end
end

$stdout = BufStdout.new

loop do
  session = server.accept
  request = session.gets

    session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
    load 'h2o.rb'
    
    template = H2o::Template.new('./something.html')
    
    session.print template.render({ :page => { :title => 'this is a title'}})
    
    session.print "<html><body><h1>#{Time.now}</h1></body></html>\r\n"
    
    session.print '<textarea rows="20" cols="50" >' + $output.inspect + '</textarea>'
    session.close
  
    $output = []
end
