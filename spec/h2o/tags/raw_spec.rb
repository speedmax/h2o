require 'spec_helper'

describe H2o::Tags::Raw do
  it "should skip h2o render between raw tag" do
    result = parse('{% raw %}{{ greeting }}{% endraw %}').render(:greeting => 'hello')
    
    result.should_not == 'hello'
    result.should == '{{ greeting }}'
  end
  
  it "should skip h2o render across multi-line" do
    result = parse(<<-eos).render(:person => 'john smith')
      {% raw %}
      <h1>{{ person }}</h1>
      {% endraw %}
    eos
    result.strip.should == '<h1>{{ person }}</h1>'
  end
  
end
