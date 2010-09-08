require 'spec_helper'

describe H2o::FileLoader do
  before do
    @path = File.expand_path("../../fixtures", __FILE__)
    @loader = H2o::FileLoader.new(@path)
  end
  
  it "search for template on a search path on file system" do
    @loader.exist?('a.html').should == true
    @loader.exist?('deep/folder/c.html').should == true
    @loader.exist?('non-existence.html').should == false
  end

  it "read for files on the searchpath" do
    @loader.read('a.html').should == '{{ hello }}'
  end
  
  it "raises error when template doesn't exist" do
    expect { @loader.read('non-existence.html') }.should raise_error
  end
  
  it "should be able to it from template class" do
    H2o::Template.load('deep/folder/c.html', :searchpath => @path).render.should == 'hello'
  end
end

describe H2o::HashLoader do
  it "read file on the same namespace in a hash" do
    H2o.loader = H2o::HashLoader.new(
      'base.html' => '{% block content %}test{% endblock %}',
      'a.html' => "{% extends 'base.html' %}{% block content %}test2{% endblock %}"
    )
    H2o.loader.read('base.html').should == '{% block content %}test{% endblock %}'
    
    H2o::Template.new('base.html').render.should == 'test'
    H2o::Template.new('a.html').render.should == 'test2'
  end
end