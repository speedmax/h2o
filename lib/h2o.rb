module H2o
  require 'pathname'

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

    def self.parse source, env = {}
      parser = Parser.new(source, false, env)
      parsed = parser.parse
    end
    
    def self.load file, env = {}
      file = env[:search_path] + file if file.is_a? String
      parser = Parser.new(file.read, file, env)
      parser.parse
    end
  end
end

require File.dirname(__FILE__) + '/core_ext/object'
require File.dirname(__FILE__) + '/core_ext/method'

require File.dirname(__FILE__) + '/h2o/constants'
require File.dirname(__FILE__) + '/h2o/errors'
require File.dirname(__FILE__) + '/h2o/nodes'
require File.dirname(__FILE__) + '/h2o/filters'
require File.dirname(__FILE__) + '/h2o/tags'
require File.dirname(__FILE__) + '/h2o/parser'
require File.dirname(__FILE__) + '/h2o/context'


