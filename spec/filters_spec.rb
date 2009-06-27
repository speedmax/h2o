require 'spec/spec_helper'

describe H2o::Filters do

  it "should pass input object as first param" do    
    H2o::Filters << TestFilters
    
    
    # try a standard filter
    render('{{ "something" | upper }}').should == 'SOMETHING'

    # # try a array input object
    list = ["man","women"]
    render('{{ object| test_filter }}', :object => list).should == list.inspect
    
    # Try a array subclass
    list = CustomCollection.new(["man", "woman"])
    render('{{ object| test_filter }}', :object => list).should == list.inspect
  end
  
  it "should be able to pass aditional parameters" do
    render('{{ "test"| test_filter_2 1, 2 }}').should == 'test-1-2'
  end
end

describe DefaultFilters do

  it "should privide a set of default filters" do
    
    render('{{ "test" |upper }}').should == 'TEST'
    
    render('{{ "TEST" |lower }}').should == 'test'
    
    render('{{ "test" |capitalize }}').should == 'Test'
    
    render('{{ list |first }}', :list => [1,2]).should == "1"
    
    render('{{ list |last }}', :list => [1,2]).should == "2"
    
    render('{{ list |join }}', :list => [1,2]).should == "1, 2"

  end

end

# 
module TestFilters
  def test_filter (input)
    "#{input.inspect}"
  end
  
  def test_filter_2 (string, param1, param2)
   "#{string}-#{param1}-#{param2}"
  end
end

class CustomCollection < Array
end

def render(src, context = {})
  H2o::Template.parse(src).render(context)
end
