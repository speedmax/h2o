module H2o
  module Tags
    @tags = {}
    class << self
      def [] name
        @tags[name]
      end

      def register(tag, name)
        @tags[name] = tag
      end
    end
    
    class Tag < Node; end

    class If < Tag
      def initialize(parser, argstring)
        @else = false
        @body = parser.parse(:else, :endif)
        @else = parser.parse(:endif) if parser.token.include? 'else'
        @negated = false
        
        
        argstring.split(/(and|or)/)
        @args = Parser.parse_arguments(argstring)
        
        # Negated condition
        first = @args.first
        if first.is_a?(Hash) && [:"!", :not].include?(first[:operator])
          @negated = true
          @args.shift
        end
      end

      def render(context, stream)
        if test(context)
          @body.render(context, stream)
        else
          @else.render(context, stream) if @else
        end
      end

      def test(context)
        if @args.size == 1 && @args.first.is_a?(Symbol)
          object = context.resolve(@args.first)
          if object == false
            result = false
          elsif object.respond_to? :length
            result = object.length != 0
          elsif object.respond_to? :size
            result = object.size != 0
          else
            result = !object.nil?
          end
        end
        return (@negated ? !result : result)
      end
      
      Tags.register(self, :if)
    end

    class For < Tag
      Syntax = /(\w+)\s+in\s+(\w+)\s*(reversed)?/

      def initialize(parser, argstring)
        @else = false
        @body = parser.parse(:else, :endfor)
        @else = parser.parse(:endfor) if parser.token.include? 'else'

        if argstring.match Syntax
          @item = $1.to_sym
          @iteratable = $2
          @reverse = !$3.nil?
        else
          raise SyntaxError, "Invalid for loop syntax "
        end
      end

      def render(context, stream)
        iteratable = context.resolve(@iteratable)
        iteratable.reverse! if @reverse
        
        length = 0
        if iteratable.respond_to? :each
          length = iteratable.size || iterabe.length
        end
        

        if length > 0
          index = 0
          parent = context[:loop]
          context.push
          
          # Main iteration
          iteratable.each do |item|
            break if index == length
            is_even = index % 2 != 0
            rev_count = length - index
            context[@item] = item
            context[:loop] = {
              :parent => parent,
              :first => index == 0,
              :counter => index + 1,
              :counter0 => index,
              :revcounter => rev_count,
              :revcounter0 => rev_count - 1,
              :last => rev_count == 1,
              :even => is_even,
              :odd => !is_even
            }
            @body.render(context, stream)
            index += 1
          end
          context.pop
        else
          # Else statement
          @else.render(context, stream) if @else
        end
        nil
      end
      Tags.register(self, :for)
    end

    # Block tag allows to divide document into reusable blocks
    #
    class Block < Tag
      attr_reader :name
      @name
      def initialize parser, argstring
        @name = argstring.to_sym
        @stack = [ parser.parse(:endblock) ]
        blocks = parser.storage[:blocks] ||= {}

        raise SyntaxError, "block name needs to be unique" if blocks.include? @name

        blocks[@name] = self
      end

      def stack_size
        @stack.size
      end

      def add_layer nodelist
        @stack << nodelist
      end

      def render context, stream, index=-1
        context.push
        context[:block] = BlockContext.new(self, context, stream, index)

        # initial -1 index always refer to the last item in ruby
        @stack[index].render(context, stream)
        context.pop
        nil
      end
      Tags.register(self, :block)
    end

    class Extends < Tag
      Syntax = /\"(.*?)\"|\'(.*?)\'/
      
      @nodelist
      def initialize parser, argstring
        unless parser.first 
          raise SyntaxError, "extend tag needs to be at the beginning of the document"
        end
        
        # parser the entire subtemplate
        parser.parse()

        # load the parent template into nodelist
        @nodelist = Template.load(argstring[1...-1])

        blocks = (@nodelist.parser.storage[:blocks] || {})
        
        (parser.storage[:blocks] || []).each do |name, tag|
          blocks[name].add_layer(tag) if blocks.include? name
        end
      end

      def render context, stream
       @nodelist.render(context, stream)
      end
      Tags.register(self, :extends)
    end
  end
end