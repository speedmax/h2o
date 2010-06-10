require 'spec_helper'

class User
  h2o_expose :name, :age
  attr_accessor :name, :age
  
  def initialize name, age
    @name, @age = name, age
  end
  
  def to_h2o
    {
      :name => self.name,
      :age => self.age
    }
  end
end

describe H2o::Context do
  before do
    @scope = {
      :person => {'name' => 'peter', 'age' => 18},
      :weather => 'sunny and warm',
      :items => ['apple', 'orange', 'pear'],
      :user => User.new('taylor', 19)
    }
    @context = H2o::Context.new(@scope)    
  end


  describe "Resolve name" do
    it "should resolve name with either string or symbol" do
      @context.resolve(:person).should == @scope[:person]
      @context.resolve(:person).should == @scope[:person]
    end
  
    it "should return nil for non existing name context" do
      @context.resolve(:something).should be_nil
      @context.resolve(:where_is_that).should be_nil
    end

    it "should be able to resolve local variables" do
      @context.resolve(:person).should_not be_nil
      @context.resolve(:'person.name').should == 'peter'
      @context.resolve(:'person.age').should == 18
    end
  
    it "should resolve array index using (dot)" do
      @context.resolve(:'items.0').should == 'apple'
      @context.resolve(:'items.1').should == 'orange'
    end
  
    it "should resolve array methods such as length, count ..." do
      @context.resolve(:'items.length').should == @scope[:items].length
      @context.resolve(:'items.first').should == 'apple'
      @context.resolve(:'items.last').should == 'pear'
    end
  
    it "should resolve object methods" do
    
      @context.resolve(:'user.name').should == 'taylor'
      @context.resolve(:'user.age').should == 19
    end

  
    it "should resolve proc object and cache inline" do
      @context.stack do
        @context['procs'] = {
          :test => lambda{ "testing" },
          :generation => lambda{ Time.now }
        }
      
        # Resolve a proc object
        @context.resolve(:'procs.test').should == 'testing'
        result = @context.resolve(:'procs.generation')
        result.should be_a(Time)
    
        # Cached inline
        @context.resolve(:'procs.generation').usec.should == result.usec
        @context.resolve(:'procs.generation').usec.should == result.usec
      end
    end
  end

  describe "Local lookup" do      
    it "should allow local variable lookup with using symbol" do
      @context[:person].should be_kind_of(Hash)
      @context[:weather].should =~ /sunny/

    end

    it "should able to set new name and value into context" do
      @context[:city] = 'five dock'
      @context[:state] = 'nsw'

      @context[:city].should == 'five dock'
      @context[:state].should == 'nsw'
    end
  end

  describe "Context stack" do
    it "should allow pushing and popping local context layer in the stack" do
      @context.push
      @context[:ass] = 'hole'
      @context[:ass].should == 'hole'
      @context.pop
    
      @context.push(:bowling => 'on sunday')
      @context[:bowling].should_not be_nil
      @context.pop    
    end
  
    it "should allow using stack method to ease push/pop and remain in local context" do
      @context.stack do
        @context[:name] = 'a'
  
        @context.stack do
          @context[:name] = 'b'
    
          @context.stack do
            @context[:age] = 19
            @context[:name] = 'c'
            @context.resolve(:'name').should == 'c'
          end
        
          @context.resolve(:'age').should == nil
          @context.resolve(:'name').should == 'b'
        end
    
        @context.resolve(:'name') == 'a'
      end
    end
  end
end
