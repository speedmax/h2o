
module H2o
  BLOCK_START = '{%'
  BLOCK_END = '%}'
  VAR_START = '{{'
  VAR_END = '}}'
  COMMENT_START = '{*'
  COMMENT_END = '*}'

  PIPE_RE = /\|/
  SEPERATOR_RE = /,/
  FILTER_END_RE = /;/
  
  NIL_RE = /nil|null|none/
  WHITESPACE_RE = /\s+/m
  BOOLEAN_RE = /true|false/
  NUMBER_RE = /\d+(\.\d*)?/
  OPERATOR_RE = /(?:>=|<=|!=|==|>|<|!|and|not|or)/
  
  STRING_RE = /
    (?:
      "([^"\\]*(?:\\.[^"\\]*)*)"
      |
      '([^'\\]*(?:\\.[^'\\]*)*)'
    )
    /xm
  
  IDENTIFIER_RE = /[a-zA-Z_][a-zA-Z0-9_]*/

  NAME_RE = /
    #{IDENTIFIER_RE}
    (?:\.[a-zA-Z0-9][a-zA-Z0-9_-]*)*
  /x
  
  NAMED_ARGS_RE = /
    (#{NAME_RE})(?:#{WHITESPACE_RE})?
    :
    (?:#{WHITESPACE_RE})?(#{STRING_RE}|#{NUMBER_RE}|#{NAME_RE})
  /x
end