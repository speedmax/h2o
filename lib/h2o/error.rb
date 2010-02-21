module H2o
  class Error < Exception; end
  
  class RuntimeError < Error ;end
  class SyntaxError < Error ;end
  class TemplateNotFound < Error ;end
  class ParserError < Error ;end
  class FilterError < Error ;end
end