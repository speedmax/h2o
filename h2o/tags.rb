module H2o::Tags
  @tags = {}
  class << self
    def [] name
      @tags[name]
    end
    
    def register(tag, name)
      @tags[name] = tag
    end
  end
  
  class Tag < ::H2o::Node; end
  
  class If < Tag
    def initialize(parser, argstring)
      @else = false
      @body = parser.parse(:else, :endif)
      @else = parser.parse(:endif) if parser.token.include? 'else'
      
    end
    
    def render (context, stream)
    end
    
    H2o::Tags.register(self, :if)
  end
  
  class For < Tag
    Syntax = /(\w+)\s+in\s+(\w+)\s*(reversed)?/
    
    def initialize(parser, argstring)
      @else = false
      @body = parser.parse(:else, :endfor)
      @else = parser.parse(:endfor) if parser.token.include? 'else'
      
      puts argstring
    end
    
    def render(context, stream)
    end
    H2o::Tags.register(self, :for)
  end

  # Block tag allows to divide document into reusable blocks
  #
  class Block < Tag
    attr_reader :name
    @name
    def initialize parser, argstring
      @name = argstring.to_sym
      @stack = [ parser.parse(:endblock) ]
      blocks = parser.storage[:blocks] ||= {}
      
      blocks[@name] = self
    end
    
    def stack_size
      @stack.size
    end
    
    def add_layer nodelist
      @stack << nodelist
    end
    
    def render context, stream, index=-1
      context.push
      context[:block] = H2o::BlockContext.new(self, context, stream, index)
      
      # initial -1 index always refer to the last item in ruby
      @stack[index].render(context, stream)
      context.pop
      nil
    end
    H2o::Tags.register(self, :block)
  end
  
  class Extends < Tag
    @nodelist
    def initialize parser, argstring
      raise "extend tag needs to be at the beginning of the document" unless parser.first 
      
      # parser the entire subtemplate
      parser.parse()
      
      # load the parent template into nodelist
      @nodelist = H2o::Template.load(argstring[1...-1])
      
      blocks = (@nodelist.parser.storage[:blocks] || {})

      (parser.storage[:blocks] || []).each do |name, tag|
        blocks[name].add_layer(tag) if blocks.include? name
      end
    end
    
    def render context, stream
     @nodelist.render(context, stream)
    end
    H2o::Tags.register(self, :extends)
  end
end