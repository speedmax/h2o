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
      @filters = filters.empty? ? nil : filters
    end
    
    def render(context, stream)
      variable = context.resolve(@name)
      variable = context.apply_filters(variable, @filters) if @filters
      # variable = variable.to_s.gsub(/&/, '&amp;')\
      #                         .gsub(/>/, '&gt;')\
      #                         .gsub(/</, '&lt;')
      
      stream << variable
    end
  end

  class CommentNode < Node
  end

end