module H2o
  module Tags
    # Block tag allows to divide document into reusable blocks
    #
    class Block < Tag
      attr_reader :name
      attr_accessor :parent

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
        context.stack do
          context[:block] = BlockContext.new(self, context, stream, index)
          @stack[index].render(context, stream)
        end
      end
      Tags.register(self, :block)
    end
  end
end
