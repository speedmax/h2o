#!/usr/bin/ruby
require 'socket'

class Server
  attr_reader :server
  def initialize ip, port
    raise "Please supply a valid ip and port" unless ip && port
    
    puts "Listening to request #{ip}:#{port}"
    puts "-----------------------------------"
    @server = TCPServer.new(ip, port.to_i)
  end
  
  def self.start(address = 'localhost:80')
    ip, port = address.split(':')
    instance = new(ip, port)
    
    raise "Please give a block to run" unless block_given?
  
    while s = instance.server.accept do
      Thread.start do
        s.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
        
        begin
          yield(s)
        rescue Exception => e
          s.print "<pre>Error: #{(e.inspect)}</pre>"
          s.print "<pre>stack: #{e.backtrace.join("\n")}</pre>"
        ensure
          s.print "\r\n"
          s.close
        end
      end
    end
  end
end

