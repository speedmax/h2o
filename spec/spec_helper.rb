require 'rubygems'
require 'spec'
require 'pp'

$: << File.join(File.dirname(__FILE__), "../lib")

require 'h2o'


def parse(source)
  H2o::Template.parse(source)
end
