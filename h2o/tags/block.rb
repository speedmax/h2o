module H2o
  module Tags
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
