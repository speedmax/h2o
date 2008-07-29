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
        elsif  object.class.ancestors.include?(DataObject) && \
                object.respond_to?(part_sym) && value = object.__send__(part_sym)
          object = value
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
          if arg.kind_of? Symbol
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
  
  class DataObject
    INTERNAL_METHOD = /^__/
    @@required_methods = [:__send__, :__id__, :respond_to?, :extend, :methods, :class, :nil?]
    
    def initialize(context)
      @context = context
    end

    def respond_to?(method)
      method_name = method.to_s
      return false if method_name =~ INTERNAL_METHOD
      return false if @@required_methods.include?(method_name)
      super
    end

    # remove all standard methods from the bucket so circumvent security
    # problems
    instance_methods.each do |m|
      unless @@required_methods.include?(m.to_sym)
        undef_method m
      end
    end 
  end
  
  class BlockContext < DataObject
    def initialize(block, context, stream, index)
      @block, @context, @stream, @index = block, context, stream, index
    end
    
    def super
      @block.render(@context, @stream, @index-1) if @block.stack_size >= @index.abs
    end
    
    def depth
      @index.abs
    end
    
    def name
      @block.name
    end
  end
end