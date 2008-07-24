

module H2o
  
  require 'pathname'
  load 'h2o/constants.rb'
  load 'h2o/parser.rb'

  class Template
    def initialize (filename, options = {})
      @file = Pathname.new(filename)
      @parser = Parser.new(@file.read, @file)
      puts 'asdfasdf'
    end
    
    def render 
      
    end    
  end

end