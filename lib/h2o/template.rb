module H2o
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