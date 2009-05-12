require 'spec/spec_helper'
require 'pp'

describe "Parser regex" do
  
  it "should match whitespace" do
    H2o::WHITESPACE_RE.should =~ '   '
    H2o::WHITESPACE_RE.should =~ ' '
  end
  
  it "should match variable names" do
    H2o::NAME_RE.should =~ 'variable'
    H2o::NAME_RE.should =~ 'variable.property'
    H2o::NAME_RE.should =~ 'variable.property'
  end
  
  it "should match string" do
    H2o::STRING_RE.should =~ '"this is a string"'
    H2o::STRING_RE.should =~ '"She has \"The thing\""'
    H2o::STRING_RE.should =~ "'the doctor is good'"
    H2o::STRING_RE.should =~ "'She can\'t do it'"
  end
  
  it "should match numeric values" do
    H2o::NUMBER_RE.should =~ '1.2'
    H2o::NUMBER_RE.should =~ '-3.2'
    H2o::NUMBER_RE.should =~ '100000'
  end
  
  it "should match operators" do
    %w(== > < >= <= != ! not and or).each do |operator|
      H2o::OPERATOR_RE.should =~ operator
    end
  end
  
  it "should match named arguments" do
    named_args = ["name: 'peter'", 'name: object.property', 'price: 2.3', 'age: 29', 'alt: "my company logo"']
    named_args.each do |arg|
      H2o::NAMED_ARGS_RE.should =~ arg
    end
  end
end

describe 'H2o::Parser argument parsing' do
  
  it "should parse named arguments" do
    r = H2o::Parser.parse_arguments(
      "something | filter 11, name: 'something', age: 18, var: variable, active: true"
    )
    
    r.should == [:something, 
      [:filter, 11, { 
        :name=> "something", 
        :age => 18, 
        :var=> :variable, 
        :active => true }
      ]
    ]
  end
end


describe "Whitespace stripping syntax" do
  it "should rstrip previous text node for {%- %}" do
    H2o::Template.parse('   {%- if true %}{% endif %}').render.should == ''
  end
    
  it "should lstrip next text node for {% -%}" do
    H2o::Template.parse('{% if true -%}   {% endif %}').render.should == ''
  end

  it "should strip whitespace on both site with {%- -%}" do
    H2o::Template.parse('
      {%- if true -%}
        hello
      {%- endif -%}   
    ').render.should == 'hello'
  end

end