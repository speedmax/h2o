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
    @stack = []
    def initialize(parser, position = 0); end    
    
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
  end
  
  class VariableNode < Node
    
    
  end

  class CommentNode < Node
  end

end