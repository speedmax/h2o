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
