
$: << File.join(File.dirname(__FILE__), "../lib")

require 'h2o'
require 'pp'

def parse(source)
  H2o::Template.parse(source)
end