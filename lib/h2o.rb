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
    
    def initialize (filename, env = {})
      @file = Pathname.new(filename)
      env[:search_path] = @file.dirname
      @nodelist = Template.load(@file, env)
    end
    
    def render (context = {})
      @context = Context.new(context)
      output_stream = []
      @nodelist.render(@context, output_stream)
      output_stream.join
    end

    def self.parse source, env
      parser = Parser.new(source, file, env)
      parser.parse
    end
    
    def self.load file, env
      file = env[:search_path] + file if file.is_a? String
      parser = Parser.new(file.read, file, env)
      parser.parse
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

