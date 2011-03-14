require 'pathname'
require 'core_ext/object'
require 'h2o/constants'

$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module H2o
  autoload :Template,   'h2o/template'
  autoload :FileLoader, 'h2o/file_loader'
  autoload :Error,      'h2o/error'
  autoload :Context,    'h2o/context'
  autoload :Parser,     'h2o/parser'
  autoload :Node,       'h2o/nodes'
  autoload :DataObject, 'h2o/context'
  autoload :Filters,    'h2o/filters'
  autoload :Tags,       'h2o/tags'
  
  module Tags
    require 'h2o/tags/if'
    require 'h2o/tags/for'
    require 'h2o/tags/with'
    require 'h2o/tags/block'
    require 'h2o/tags/extends'
    require 'h2o/tags/raw'
  end

  def self.loader
    @loader
  end
  
  def self.loader=(loader)
    @loader = loader
  end
end
