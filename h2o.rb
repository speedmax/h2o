

module H2o
  
  require 'pathname'
  require 'h2o/constants'
  load 'h2o/nodes.rb'
  load 'h2o/filters.rb'
  load 'h2o/tags.rb'

  load 'h2o/parser.rb'
  load 'h2o/context.rb'

  class Template
    def initialize (filename, options = {})
      @file = Pathname.new(filename)
      @parser = Parser.new(@file.read, @file)
      @nodelist = @parser.parse
    end
    
    def render (context = {})
      @context = Context.new(context)
      output_stream = []
      @nodelist.render(@context, output_stream)
      output_stream
    end
    
    def to_nodelist
      @nodelist
    end
    
    def self.parse source
      
    end
    
    def self.load filename
      new(filename).to_nodelist
    end
  end

end