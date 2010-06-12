require 'spec_helper'

describe H2o::Tags::Block do
  
  it "should render block content" do
    parse('{% block something %}content{% endblock %}').render.should == 'content'
  end
  
  
  context "block variable" do
    it "should return block name" do
      parse(block(:something, '{{ block.name }}')).render.should == 'something'
    end
    
    it "should return current block depth" do
      source = block(:something, '{{ block.depth }}')
      parse(source).render.should == "1"
    end
    
    it "should return parent block content"
  end

  def block(name, content)
    "{% block #{name.to_s} %}#{content}{% endblock %}"
  end
end