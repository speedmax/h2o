
$: << File.join(File.dirname(__FILE__), "../lib")

require 'h2o'
require 'pp'

def parse(source)
  H2o::Template.parse(source)
end

class H2o::HashLoader
  def initialize(stack)
    @stack = stack
  end
  
  def read(file)
    raise "Template not find" unless exist?(file)
    @stack[file]
  end
  
  def exist?(file)
    @stack.has_key?(file)
  end
end
