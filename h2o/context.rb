module H2o
  class Context
    def initialize(context)
      @stack = context
    end
  
    def [](name); 
      @stack.each do |layer|
        value = layer[name]
        return value unless value.nil?
      end
    end
    
    def []=(name, value); end
    
    def resolve(path); 
      current=self
      path.split(/\./).each do |part|
        sym = part.to_sym
        
        
      end
    end
    
    def defined?(name); end
    
    def apply_filters(object, filters);
      object
    end
  end
    
  class BlockContext
    attr_reader :name
    
    def initialize(block, name, index)
      @block, @name, @index = block, name, index
    end
    
    def super
      @block.render()
    end
    
    def depth
      @index+1
    end
  end
end