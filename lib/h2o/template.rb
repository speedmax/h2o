module H2o
  class Template
    attr_reader :context
    
    def initialize (file, env = {})
      @file = file
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
      unless H2o.loader
        env[:searchpath] ||= File.expand_path('../', file)
        H2o.loader = H2o::FileLoader.new(env[:searchpath])
      end
      source = H2o.loader.read(file)
      
      parser = Parser.new(source, file, env)
      parser.parse
    end
  end
end