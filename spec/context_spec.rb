require 'spec/spec_helper'

scope = {
  :person => {:name => 'peter', :age => 18},
  :weather => 'sunny and warm',
  :items => ['apple', 'orange', 'pear']
}
context = H2o::Context.new(scope)

describe "Resolve name" do
  it "should resolve name with either string or symbol" do
    context.resolve(:person).should == scope[:person]
    context.resolve("person").should == scope[:person]
  end
  
  it "should return nil for non existing name context" do
    context.resolve('something').should be_nil
    context.resolve('where_is_that').should be_nil
  end

  it "should be able to resolve local variables" do
    context.resolve('person').should_not be_nil
    context.resolve('person.name').should == 'peter'
    context.resolve('person.age').should == 18
  end
  
  it "should resolve array index using (dot)" do
    context.resolve('items.0').should == 'apple'
    context.resolve('items.1').should == 'orange'
  end
  
  it "should resolve array methods such as length, count ..." do
    context.resolve('items.length').should == scope[:items].length
    context.resolve('items.first').should == 'apple'
    context.resolve('items.last').should == 'pear'
  end
end

describe "Local lookup" do      
  it "should allow local variable lookup with using symbol" do
    context[:person].should be_kind_of(Hash)
    context[:weather].should =~ /sunny/

    context["person"].should == nil
    context["weather"].should == nil
  end

  it "should able to set new name and value into context" do
    context[:city] = 'five dock'
    context[:state] = 'nsw'

    context[:city].should == 'five dock'
    context[:state].should == 'nsw'
  end
end
  
describe "Context stack" do
  it "should allow pushing and popping local context layer in the stack" do
    context.push
    context[:ass] = 'hole'
    context[:ass].should == 'hole'
    context.pop
    
    context.push(:bowling => 'on sunday')
    context[:bowling].should_not be_nil
    context.pop    
  end
  
  it "should allow using stack method to ease push/pop and remain in local context" do
    context.stack do
      context[:name] = 'a'
  
      context.stack do
        context[:name] = 'b'
    
        context.stack do
          context[:name] = 'c'
          context.resolve('name').should == 'c'
        end
        
        context.resolve('name').should == 'b'
      end
    
      context.resolve('name') == 'a'
    end
  end
end

