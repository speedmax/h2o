require 'spec_helper'

describe H2o::Tags::If do
  it "should render if body when expression evaluated as true" do
    parse('{% if true %}if body{% endif %}').render.should == 'if body'    
  end
  
  it "should render else body when expression yields false" do
    parse('{% if !true %}{% else %}else body{% endif %}').render.should == 'else body'
  end
  
  describe "Basic type comparisons" do
    it "should compare numbers" do
      parse('{% if 3 > 2 %}Yes{% endif %}').render.should == 'Yes'
    end
    
    it "should compare string" do
      parse('{% if "z" > "a" %}Y{% endif %}').render.should == 'Y'
    end
    
    it "should compare variables" do
      parse('{% if a >= b %}Y{% endif %}').render(:a=>2, :b=>1).should == 'Y'
    end
  end
  
  describe "logical comparisons" do
    it "should perform left > right comparison" do
      parse('{% if 3 > 2 %}Yes{% endif %}').render.should == 'Yes'
      
    end
    
    it "should perform left >= right comparison" do
      parse('{% if 3 >= 2 %}Y{% endif %}').render.should == 'Y'
      
    end
    
    it "should perform left >= right comparison" do
      parse('{% if 3 >= 2 %}Y{% endif %}').render.should == 'Y'
    end
  end
  
  describe "Binary logics" do
    it "should evaluate a true expression" do
      parse('{% if true %}truth{% endif %}').render.should == 'truth'
    end
    
    
    it "should negate a expression with not or !" do
      parse('{% if not false %}truth{% endif %}').render.should == 'truth'
      
      parse('{% if !false %}truth{% endif %}').render.should == 'truth'
      
      parse('{% if !page.editable %}Locked{% else %}Editable{% endif %}').render(:page=>{:editable => true}).should == 'Editable'
      
      parse('{% if ! 2 > 3 %}Y{% endif %}').render.should == 'Y'
    end
  end
end
