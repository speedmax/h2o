module H2o
  require 'pathname'

  class Stream < Array
    
    def << (item)
      unshift item.to_s
    end
    
    def close
      reverse!
    end
  end

  class Template
    attr_reader :context
    
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

require 'h2o/constants'
require 'h2o/errors'
require 'h2o/nodes'
require 'h2o/filters'
require 'h2o/tags'
require 'h2o/parser'
require 'h2o/context'

