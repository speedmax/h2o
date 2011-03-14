module H2o
  module Tags
    class Raw < Tag
      def initialize(parser, argstring)
        @body = parser.parse(:endraw)
      end
      
      def render(context, stream)
        raw_body = @body.parser.source.gsub(/\{%\s?(:?end)?raw\s?%\}/sm, '')
        
        stream << raw_body
      end
      
      Tags.register(self, :raw)
    end
    
  end
end
  