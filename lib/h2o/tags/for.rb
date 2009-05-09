module H2o
  module Tags
    class For < Tag
      Syntax = /
        (?:(#{H2o::IDENTIFIER_RE}),\s?)?
        (#{H2o::IDENTIFIER_RE})\s+in\s+(#{H2o::NAME_RE})\s*
        (reversed)?
      /x

      def initialize(parser, argstring)
        @key = false
        @else = false
        @body = parser.parse(:else, :endfor)
        @else = parser.parse(:endfor) if parser.token && parser.token.include?('else')
        
        if matches = Syntax.match(argstring)
          @key = $1.to_sym unless $1.nil?
          @item = $2.to_sym
          @iteratable = $3.to_sym
          @reverse = !$4.nil?
        else
          raise SyntaxError, "Invalid for loop syntax "
        end
      end

      def render(context, stream)
        iteratable = context.resolve(@iteratable)
        iteratable.reverse! if @reverse
        length = 0

        if iteratable.respond_to?(:each)
          length = iteratable.size || iterabe.length
        end
        
        if length > 0
          parent = context[:loop]
          # Main iteration
          context.stack do
            iteratable.each_with_index do |*args|

              if args.first.is_a? Array
                keyvalue, index = args
                key, value = keyvalue
              else
                value, index = args
                key = index
              end
              
              is_even = index % 2 != 0
              rev_count = length - index
              context[@item] = value
              context[@key] = key
              context[:loop] = {
                :parent => parent,
                :first => index == 0,
                :last => rev_count == 1,
                :counter => index + 1,
                :counter0 => index,
                :revcounter => rev_count,
                :revcounter0 => rev_count - 1,
                :even => is_even,
                :odd => !is_even
              }
              @body.render(context, stream)
            end
          end
        else
          # Else statement
          @else.render(context, stream) if @else
        end
        nil
      end
      Tags.register(self, :for)
    end

  end
end