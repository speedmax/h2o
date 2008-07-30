module H2o
  class FilterCollection 
    def self.each_filter (&block)
      instance = self.new
      instance_methods(false).each do |method|
        name = method.to_sym
        filter = instance.method(name).to_proc
        block.call(name, filter)
      end
    end
  end
  
  class StandardFilters < FilterCollection
    def upper value
      value.to_s.upcase
    end
    
    def lower value
      value.to_s.downcase
    end
    
    def capitalize value
      value.to_s.capitalize
    end
    
    def escape value, attribute=false
      value = value.to_s.gsub(/&/, '&amp;')\
                       .gsub(/>/, '&gt;')\
                       .gsub(/</, '&lt;')
      value.gsub!(/"/, '&quot;') if attribute
      value
    end

    
    def test value, arg1, arg2
      "#{value} #{arg1} #{arg2}" 
    end
  end

  module Filters
    @filters = {}
    # Class methods of filters
    class << self
      def [] name
        @filters[name]
      end
      
      def register_collection(collection)
        raise 'Collection needs to be a kind of FilterCollection' unless collection.ancestors.include? FilterCollection
        collection.each_filter do |name, filter|
          @filters[name] = filter
        end
        nil
      end
      
      def register name, filter
        @filters[name] = filter
      end
      
      def add name, &block
        raise "Require a block" unless block
        @filters[name] = block
      end
      
      def all
        @filters.keys
      end
    end
  end
  Filters.register_collection StandardFilters
end