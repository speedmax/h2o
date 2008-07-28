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
  
  class Tag < ::H2o::Node
  end
  
  class If < Tag
    def initialize(parser, argstring)
      
    end
    
    def render (context, stream)
    end
  end
  
  class For < Tag
  end
  
  class Block < Tag
  end
  
  class Extends < Tag
  end
end