module H2o
  class Context
    def initialize(context)
      @context = context
    end
  
    def [](value); end
    
    def []=(name, value); end
    
    def resolve(namespace); end
    
    def defined?(name); end
    
    def appliy_filters(object, filters);end
  end
    
  class BlockContext
    attr_reader :name
    
    def initialize(block, name, index)
      @block, @name, @index = block, name, index
    end
    
    def super
      @block->render()
    end
    
    def depth
      @index+1
    end
  end
end