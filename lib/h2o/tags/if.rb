module H2o
  module Tags
    class If < Tag
      def initialize(parser, argstring)
        @else = false
        @body = parser.parse(:else, :endif)
        @else = parser.parse(:endif) if parser.token.include? 'else'
        @negated = false
        @args = Parser.parse_arguments(argstring)
        
        # Negated condition
#        first = @args.first
#        if first.is_a?(Hash) && [:"!", :not].include?(first[:operator])
#          @negated = true
#          @args.shift
#        end
      end

      def render(context, stream)
        if self.evaluate(context)
          @body.render(context, stream)
        else
          @else.render(context, stream) if @else
        end
      end
      
      def evaluate(context)
        if @args.size == 1
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
        elsif @args.size == 2
          op, operant = @args
          if (op.is_a?(Hash) && [:'!', :not].include?(op[:operator]))
            object = context.resolve(operant) if right.is_a? Symbol
            result = !object
          end
        elsif @args.size == 3
          left, op, right = @args
          right = context.resolve(right) if right.is_a? Symbol
          left = context.resolve(left) if left.is_a? Symbol
          result = comparisons(op[:operator], left, right)
        end
        return result
      end
      
      def comparision(operator, left, right)
        tests = {
          :>  => lamda{|l,r| l > r },
          :>= => lamda{|l,r| l >= r },
          :== => lamda{|l,r| l == r },
          :<  => lamda{|l,r| l < r},
          :<= => lamda{|l,r| l <= r}
        }
        
        tests[operator.to_sym] ? 
          tests[operator.to_sym].call(left,right) : false
      end
      
      Tags.register(self, :if)
    end
  end
end