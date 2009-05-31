require 'spec/spec_helper'
require 'pp'

describe "Filter parameter passing" do
  it "should pass input object as first param" do
    
    # try a standard filter
    parse('{{ "something" | upper }}').render.should == 'SOMETHING'
    

    # try a array input object
    H2o::Filters.add(:test_filter) do |input|
      "#{input.inspect}"
    end
    
    list = ["man","women"]
    result = parse('{{ object| test_filter }}').render(:object => list)
    result.should == list.inspect
    
    # Try a array subclass
    list = CustomCollection.new(["man", "woman"])
    
    result = parse('{{ object| test_filter }}').render(:object => list)
    result.should == list.inspect
  end
  
  it "should be able to pass aditional parameters" do
    H2o::Filters.add(:test_filter) do |string, param1, param2|
      "#{string}-#{param1}-#{param2}"
    end
    parse('{{ "test"| test_filter 1, 2 }}').render.should == 'test-1-2'
  end
end

describe 'Standard Filters' do
  it "should upcase an string" do
      parse('{{ "test" | upper }}').render.should == 'TEST'
  end
end


def parse src
  H2o::Template.parse(src)
end

class CustomCollection < Array; end