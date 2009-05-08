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

require File.dirname(__FILE__) + '/tags/if'
require File.dirname(__FILE__) + '/tags/for'
require File.dirname(__FILE__) + '/tags/block'
require File.dirname(__FILE__) + '/tags/with'