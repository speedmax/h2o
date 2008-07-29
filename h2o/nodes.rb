module H2o
  class Node 
    def initialize(parser, position = 0)
    end
    
    def render(context, stream)
    end
  end
  
  # Nodelist
  #
  class Nodelist < Node
    attr_reader :parser
    
    def initialize(parser, position = 0)
     @parser = parser
     @stack = []  
    end
    
    def render(context, stream)
      @stack.each do |node|
        node.render(context, stream)
      end
    end
    
    def <<(node)
      @stack << node
    end

    def length
      @stack.length
    end
  end
  
  class TextNode < Node
    def initialize(content)
      @content = content
    end
    
    def render(context, stream)
      stream << @content
    end
  end
  
  class VariableNode < Node
    def initialize (name, filters)
      @name = name
      @filters = filters
    end
    
    def render(context, stream)
      if (@name == :'loop.parent.counter')
        puts 'this is it man'
        puts context.inspect
        puts context.resolve(:'loop.parent')
      end
      
      variable =  context.apply_filters(context.resolve(@name), @filters)
      stream << variable
    end
  end

  class CommentNode < Node
  end

end