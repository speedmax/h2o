module H2o
  module Tags
    class With < Tag
      Syntax = /(#{NAME_RE})\s+as\s+(#{NAME_RE})/

      def initialize(parser, argstring)
        @body = parser.parse(:endwith)
        
        if argstring =~ Syntax
          @name = $1.to_sym
          @shortcut = $2.to_sym
        else
          raise SyntaxError, "Invalid with syntax "
        end
      end

      def render(context, stream)
        object = context.resolve(@name)
        context.stack do
          context[@shortcut] = object
          @body.render(context, stream)
        end
      end
      Tags.register(self, :with)
    end

  end
end