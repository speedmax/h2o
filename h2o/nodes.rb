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
   
    def initialize(position = 0);
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
      variable =  context.apply_filters(context.resolve(@name), @filters)
      puts variable
      stream << variable
    end
  end

  class CommentNode < Node
  end

end