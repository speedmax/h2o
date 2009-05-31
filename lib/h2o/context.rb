module H2o
  class Context

    def initialize(context ={})
      @stack = [context]
    end

    # doing a reverse lookup
    # FIXME: need to double check this, also changed Block#add_layer in reverse order
    def [](name)
      @stack.each do |layer|
        value = layer[name]
        return value unless value.nil?
      end
      nil
    end
    
    def []=(name, value)
      @stack.first[name] = value
    end

    def pop
      @stack.shift if @stack.size > 1
    end
    
    def push(hash = {})
      @stack.unshift hash
    end
    
    def stack
      result = nil
      push
      begin
        result = yield
      ensure
        pop
      end
      result
    end

    def resolve(name)
      return name unless name.is_a? Symbol
      
      object = self
      parts = name.to_s.split('.')
      part_sym = nil

      parts.each do |part|
        part_sym = part.to_sym

        # Hashes
        if object.respond_to?(:has_key?) && (object.has_key?(part_sym) || object.has_key?(part))
            result = object[part_sym] || object[part]
            # Proc object with extra caution
            begin
              result = object[part_sym] = result.call if result.is_a?(Proc) && object.respond_to?(:[]=)
            rescue
              return nil
            end
            object = result
      
        # Array and Hash like objects
        elsif part.match(/^-?\d+$/)
          if (object.respond_to?(:has_key?) || object.respond_to?(:fetch)) && value = object[part.to_i]
            object = value
          else
            return nil
          end
        
        # H2o::DataObject Type
        elsif (object.is_a?(DataObject) || object.class.h2o_safe_methods && object.class.h2o_safe_methods.include?(part_sym) )&& \
              object.respond_to?(part_sym)
          object = object.__send__(part_sym)
        
        # Sweet array shortcuts
        elsif object.respond_to?(part_sym) && [:first, :length, :size, :last].include?(part_sym)
          object = object.__send__(part_sym)
        else
          return nil
        end
      end
      
      object
    end

    def has_key?(key)
      !send(:[], key).nil?
    end
    
    def apply_filters(object, filters)
      filters.each do |filter|
        name, *args = filter
        filter = Filters[name] 
        
        raise FilterError, "Filter(#{name}) not found" if filter.nil?
        
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
    @@required_methods = [:__send__, :__id__, :object_id, :respond_to?, :extend, :methods, :class, :nil?, :is_a?]
    
    def initialize(context)
      @context = context
    end

    def respond_to?(method)
      method_name = method.to_s
      return false if method_name =~ INTERNAL_METHOD
      return false if @@required_methods.include?(method_name)
      super
    end

    # remove all standard methods for security
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
      @block.parent.render(@context, @stream, @index-1) if @block.parent.stack_size > @index.abs
      nil
    end
    
    def depth
      @index.abs
    end
    
    def name
      @block.name
    end
  end
end