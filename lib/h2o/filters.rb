module H2o
  module Filters
    
    class Base < H2o::DataObject
      def initialize(context)
        @context = context
      end
    end

    @filters = []

    # Class methods of filters
    class << self
      def [] name
        @filters[name]
      end
      
      def << (filter)
        @filters << filter
      end
      
      def register filter
        @filters << filter
      end
      
      def build(context)
        @base = Base.new(context)

        @filters.each do |filter|
          @base.extend(filter)
        end

        @base
      end
      
      def create name, &block
        Base.class_eval do
          define_method name, &block
        end
      end
      
      def all
        @filters
      end
    end
  end
end

require File.dirname(__FILE__) + '/filters/default'