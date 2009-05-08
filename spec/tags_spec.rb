require 'spec/spec_helper.rb'
require 'pp'

describe "For tags" do
  
  it "should iteration through array" do
    r = parse("{% for a in list %}{{ a }}{% endfor %}").render(:list => [1,2,3])
    
    r.should == '123'
  end
  
  it "should iterate through array subclass" do
    context = {:user => {:lucky_numbers => Collection.new([1,2,3,4,5,6])}}
    r = parse("{% for a in user.lucky_numbers %}{{a}}{%endfor%}").render(context)
    
    r.should == '123456'
  end
  
  it "should iterate through a hash object" do
    context = {:person => {:name => 'taylor', :age => 19}}
    r = parse("{%for a in person%}{{ a }}{% endfor %}").render(context)
    
    if RUBY_VERSION.match("1.8")
      r.should == '19taylor' 
    else
      r.should == 'taylor19'
    end
    
    r = parse("{%for a, b in person %}{{ a }}{{ b }}{% endfor %}").render(context)
    
    if RUBY_VERSION.match("1.8")
      r.should == 'age19nametaylor'
    else
      r.should == 'nametaylorage19'
    end
  end

end


def parse(source)
  H2o::Template.parse(source)
end

class Collection < Array;end