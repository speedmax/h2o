require 'spec/spec_helper.rb'
require 'pp'

describe "For tag - Iterations" do
  
  it "should iteration through array" do
    t = parse("{% for a in list %}{{ a }}{% endfor %}")
    t.render(:list => [1,2,3]).should == '123'
  end
  
  it "should iterate through array subclass" do
    t = parse("{% for i, user in users %}{{ i }}.{{ user }}{% endfor %}")
    t.render(:users =>%w(PeterIT ManHoodHero)).should == '0.PeterIT1.ManHoodHero'
  end

  it "should iterate through a hash object" do
    person = {:name => 'taylor', :age => 19 }
    
    t = parse("{% for a in person %}{{ a }}{% endfor %}")
    t.render(:person => person).should == 'taylor19'

    t = parse("{%for a, b in person %}{{ a }}{{ b }}{% endfor %}")
    t.render(:person => person).should == 'nametaylorage19'
  end
  
end


describe "For Tag - Magic loop variable" do
  
  before do
    @context = {:words=> %w(something else about this person) }
  end
  
  it "should correct iteration counters" do
    fortag('{{ loop.counter }}').render(@context).should == '12345'
    fortag('{{ loop.counter0 }}').render(@context).should == '01234'

    fortag('{{ loop.revcounter }}').render(@context).should == '54321'
    fortag('{{ loop.revcounter0 }}').render(@context).should == '43210'
  end
  
  it "should have .even and .odd iteration flag" do
    fortag('{% if loop.even %}{{ item }}{% endif %}').render(@context).should == 'elsethis'
    fortag('{% if loop.odd %}{{ item}}{% endif %}').render(@context).should == 'somethingaboutperson'
  end
  
  it "should have .first and .last flag to indicate if it's first/last iteration" do
    fortag('{%if loop.first %}{{ item }}{% endif }').render(@context).should == 'something'
    fortag('{%if loop.last %}{{ item }}{% endif }').render(@context).should == 'person'
  end
  
  it "should have parent property pointer to parent loop" do
    
    result = fortag(
      '{% for num in numbers %}{{ loop.parent.counter }}-{{ item }}{% endfor %}'
    ).render(@context.merge(:numbers=> [6,8]))
    
    result.should == '1-something1-something2-else2-else3-about3-about4-this4-this5-person5-person'
    
    result = fortag(
      '{% for num in numbers %}{% if loop.parent.first %}{{ num }}-{{ item }}{% endif %}{% endfor %}'
    ).render(@context.merge(:numbers=> [88,99,66]))

    result.should == '88-something99-something66-something'
    
  end

  def fortag(body)
    parse("{% for item in words %}#{body}{% endfor %}")
  end
end



def parse(source)
  H2o::Template.parse(source)
end
