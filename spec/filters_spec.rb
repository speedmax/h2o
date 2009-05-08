require 'spec/spec_helper'
require 'pp'

describe 'Standard Filters' do
  it "should upcase an string" do
      parse('{{ "test" | upper }}').render.should == 'TEST'
  end
end


def parse src
  H2o::Template.parse(src)
end