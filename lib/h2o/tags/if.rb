module H2o
  module Tags
    class Evaluator
      class << self
        def ==(left, right) left == right ;end
        def >(left, right) left > right; end
        def >=(left, right) left >= right; end
        def <(left, right) left < right; end
        def <= (left, right) left <= right; end
      end
    end
    
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
        if test(context)
          @body.render(context, stream)
        else
          @else.render(context, stream) if @else
        end
      end

      def test(context)
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
          result = Evaluator.send(op[:operator], left, right)
        end
        return result
      end
      
      Tags.register(self, :if)
    end
  end
end