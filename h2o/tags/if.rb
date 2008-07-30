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
  end
end