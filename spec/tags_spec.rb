require 'spec/spec_helper.rb'
require 'pp'

describe H2o::Tags::For do
  describe "Iterations" do  
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

  describe "Magic loop variable" do
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
      template = fortag '{% for num in numbers %}{{ loop.parent.counter }}-{{ item }}{% endfor %}'
      expect = '1-something1-something2-else2-else3-about3-about4-this4-this5-person5-person'
      
      template.render(@context.merge(:numbers=> [6,8])).should == expect

      template = fortag '{% for num in numbers %}{% if loop.parent.first %}{{ num }}-{{ item }}{% endif %}{% endfor %}'
      expect = '88-something99-something66-something'

      template.render(@context.merge(:numbers=> [88,99,66])).should == expect
    end

    def fortag(body)
      parse("{% for item in words %}#{body}{% endfor %}")
    end
  end
end


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

def parse(source)
  H2o::Template.parse(source)
end
