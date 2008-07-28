module H2o
  class Context
    #include Enumerable
    def initialize(context)
      @stack = [context]
    end
  
    def [](name); 
      @stack.each do |layer|
        value = layer[name]
        return value unless value.nil?
      end
      nil
    end
    
    def []=(name, value)
      @stack[-1][name] = value
    end
    
    def pop
      @stack.pop if @stack.size > 1
    end
    
    def push(hash = {})
      @stack << hash
    end
    
    def resolve(path); 
      object = self
      path.to_s.split(/\./).each do |part|
        part_sym = part.to_sym
        
        if object.respond_to?(:has_key?) && value = object[part_sym]
          object = value  
        # Works for both Array and Hash like objects
        elsif part.match /^-?\d+$/ 
          if object.respond_to?(:has_key?) || object.response_to?(:fetch) && value = object[part.to_i]
            object = value
          else
            return nil
          end
        else
          return nil
        end
      end
      object
    end
    
    def has_key?(key)
      !send(:[], key).nil?
    end
    
    def apply_filters(object, filters);
      filters.each do |filter|
        name, *args = filter
        
        filter = Filters[name] 
        raise "Filter not found" if filter.nil?
        
        args.map! do |arg|
          if arg.kind_of Symbol
            resolve(arg)
          else
            arg
          end
        end
        object = filter.call(object, *args)
      end
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