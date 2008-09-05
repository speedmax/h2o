module H2o
  class RuntimeError < Exception ;end
  class SyntaxError < Exception ;end
  class TemplateNotFound < Exception ;end
  class ParserError < Exception ;end
  class FilterError < Exception ;end
end