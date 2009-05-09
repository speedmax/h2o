module H2o
  module Tags
    class If < Tag
      @else = false
      @negated = false
      
      def initialize(parser, argstring)  
        raise SyntaxError, "If tag doesn't support Keywords(and or)" if argstring =~ / and|or /

        @body = parser.parse(:else, :endif)
        @else = parser.parse(:endif) if parser.token.include? 'else'
        @args = Parser.parse_arguments(argstring)
        
        # Negated condition
        first = @args.first
        if first.is_a?(Hash) && first[:operator] && [:"!", :not].include?(first[:operator])
         @negated = true
         @args.shift
        end
      end

      def render(context, stream)
        if self.evaluate(context)
          @body.render(context, stream)
        else
          @else.render(context, stream) if @else
        end
      end
      
      def evaluate(context)
        # Implicity evaluation
        if @args.size == 1
          object = context.resolve(@args.first)
          if object == false
            result = false
          elsif object == true
            result = true
          elsif object.respond_to? :length
            result = object.length != 0
          elsif object.respond_to? :size
            result = object.size != 0
          else
            result = !object.nil?
          end
        # Comparisons
        elsif @args.size == 3
          left, op, right = @args
          right = context.resolve(right)
          left = context.resolve(left)
          
          result = comparision(op[:operator], left, right)
        end

        return @negated ? !result : result
      end
      
      def comparision(operator, left, right)
        case operator
          when :> 
            left > right
          when :>=
            left >= right
          when :==
            left == right
          when :<
            left < right
          when :<=
            left <= right
          else
            false
        end
      end
      
      Tags.register(self, :if)
    end
  end
end