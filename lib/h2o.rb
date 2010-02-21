require 'pathname'
require 'core_ext/object'
require 'h2o/constants'

$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module H2o
  autoload :Template,   'h2o/template'
  autoload :Error,      'h2o/error'
  autoload :Context,    'h2o/context'
  autoload :Parser,     'h2o/parser'
  autoload :Node,       'h2o/nodes'
  autoload :DataObject, 'h2o/context'
  autoload :Filters,    'h2o/filters'
  autoload :Tags,       'h2o/tags'
  
  module Tags
    autoload :If,       'h2o/tags/if'
    autoload :For,      'h2o/tags/for'
    autoload :With,     'h2o/tags/with'
    autoload :Block,    'h2o/tags/block'
    autoload :Extends,  'h2o/tags/extends'
  end
end
