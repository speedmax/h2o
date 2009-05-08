require 'spec/spec_helper.rb'
require 'pp'
0
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
    pending
  end

end


def parse(source)
  H2o::Template.parse(source)
end


class Collection < Array

end