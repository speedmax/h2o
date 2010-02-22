module H2o
  module Tags
    class Extends < Tag
      Syntax = /\"(.*?)\"|\'(.*?)\'/
      
      def initialize parser, argstring
        unless parser.first? 
          raise SyntaxError, "extend tag needs to be at the beginning of the document"
        end
        # parser the entire subtemplate
        parser.parse()

        # load the parent template into nodelist
        @nodelist = Template.load(argstring[1...-1], parser.env)
        
        blocks = @nodelist.parser.storage[:blocks] || {}
        
        (parser.storage[:blocks] || []).each do |name, block|
          if blocks.include? name
            blocks[name].add_layer(block)
            block.parent =  blocks[name]
          end
        end
      end

      def render context, stream
       @nodelist.render(context, stream)
      end
      
      Tags.register(self, :extends)
    end
  end
end