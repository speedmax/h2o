module H2o
  module Tags
    @tags = {}
    class << self
      def [] name
        @tags[name]
      end

      def register(tag, name)
        @tags[name] = tag
      end
    end
    
    class Tag < Node; end
  end
end

require 'h2o/tags/if'
require 'h2o/tags/for'
require 'h2o/tags/block'