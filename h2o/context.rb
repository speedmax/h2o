module H2o
  class Context
    Pattern = {
      :string => /^["'](.*?[^\\]|.*?)["']$/,
      :float => /(-?\d+\.\d+)/,
      :integer => /^-?\d+$/,
      :bracket => /\[([^\]]+)\]/,
      :name => /\[[^\]]+\]|(?:[\w\-]\??)+/,
    }
    
    #include Enumerable
    def initialize(context ={})
      @@count = 0
      @stack = [context]
    end
  
    # doing a reverse lookup
    # FIXME: need to double check this, also changed Block#add_layer in reverse order
    def [](name); 
      @stack.each do |layer|
        value = layer[name]
        return value unless value.nil?
      end
      nil
    end
    
    def []=(name, value)
      @stack[0][name] = value
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

    def resolve(name); 
      @@count += 1
      case name
        when nil, 'nil', ''
          nil
#        when 'true'
#          true
#        when 'fase'
#          false
        when /^['"](.*)['"]$/,
          $1.to_s
        when /^-?\d+\.\d+$/
          name.to_f
        when /^-?\d+$/
          name.to_i
        else
          resolve_variable(name)
      end
    end

    def resolve_variable(name)
      object = self
      parts = name.to_s.scan(/\[[^\]]+\]|(?:[\w\-]\??)+/)
      #parts = name.to_s.split(/\./)
      part_sym = nil
      
      parts.each do |part|
        # Support bracket
        part = resolve($1) if part =~ /\[([^\]]+)\]/
        part_sym = part.to_sym
        # Hashes
        if object.respond_to?(:has_key?) && value = (object[part] || object[part_sym])
          object = value  
        # Array and Hash like objects
        elsif part.is_a?(Integer) || part.match(/^-?\d+$/)
          if object.respond_to?(:has_key?) || object.respond_to?(:fetch) && value = object[part.to_i]
            object = value
          else
            return nil
          end
        # H2o::DataObject Type
        elsif object.is_a?(DataObject) && \
              object.respond_to?(part_sym) && value = object.__send__(part_sym)
          object = value
        elsif object.respond_to?(part_sym) && [:first, :length, :size, :last].include?(part_sym) 
          object = object.__send__(part_sym)
        # May be Proc object next?
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
        raise FilterError, "Filter not found" if filter.nil?
        
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
    
    def count
      @@count
    end
  end
  
  class DataObject
    INTERNAL_METHOD = /^__/
    @@required_methods = [:__send__, :__id__, :respond_to?, :extend, :methods, :class, :nil?, :is_a?]
    
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
      @block.render(@context, @stream, @index-1) if @block.stack_size > @index.abs
    end
    
    def depth
      @index.abs
    end
    
    def name
      @block.name
    end
  end
end