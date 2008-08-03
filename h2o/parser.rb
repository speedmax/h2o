module H2o
  class Parser 
    attr_reader :token, :env
    attr_accessor :storage
    
    TAG_REGEX = /
      (.*?)(?:
        #{Regexp.escape(BLOCK_START)}    (.*?)
        #{Regexp.escape(BLOCK_END)}          |
        #{Regexp.escape(VAR_START)}      (.*?)
        #{Regexp.escape(VAR_END)}            |
        #{Regexp.escape(COMMENT_START)}  (.*?)
        #{Regexp.escape(COMMENT_END)}    
      )
    /ximo

    def initialize (source, filename, env = {})
      @env = env
      @storage = {}
      @source = source
      @filename = filename
      @tokenstream = tokenize
      @first = true
    end

    def tokenize
      result = []
      @source.scan(TAG_REGEX).each do |match|
        result << [:text, match[0]] if match[0] and !match[0].empty?
        
        if data = match[1]
          result << [:block, data.strip]
        elsif data = match[2]
          result << [:variable, data.strip]
        elsif data = match[3]
          result << [:comment, data.strip]
        end
      end
      
      rest = $~.nil? ? @source : @source[$~.end(0) .. -1]
      unless rest.empty?
        result << [:text, rest]
      end
      result.reverse
    end
    
    def first?
      @first
    end
    
    def parse(*untils)
      nodelist = Nodelist.new(self)
      
      while @token = @tokenstream.pop
        token, content = @token
        case token
          when :text :
            nodelist << TextNode.new(content) unless content.empty?
          when :variable :
            names = []
            filters = []
            Parser.parse_arguments(content).each do |argument|
              if argument.is_a? Array
                filters << argument
              else
                names << argument
              end
            end
            nodelist << VariableNode.new(names.first, filters)
          when :block :
            name, args = content.split(/\s+/, 2)
            name = name.to_sym
            
            if untils.include?(name)
              return nodelist
            end
            
            tag = Tags[name]
            raise "Unknow tag #{name}" if tag.nil?
            
            nodelist << tag.new(self, args) if tag
          when :comment :  
            nodelist << CommentNode.new(content)
        end
        @first = false
      end
      nodelist
    end

    def self.parse_arguments (argument)
      result = current_buffer = []
      filter_buffer = []
      data = nil
      ArgumentLexer.lex(argument).each do |token|
        token, data = token
        case token
          when :filter_start
            current_buffer = filter_buffer.clear
          when :filter_end
            result << filter_buffer.dup unless filter_buffer.empty?
            current_buffer = result
          when :name
            current_buffer << data.to_sym
          when :number
            current_buffer << (data.include?('.') ? data.to_f : data.to_i)
          when :string
            data.match(ArgumentLexer::STRING_RE)
            current_buffer << $1 || $2
          when :operator
            current_buffer << {:operator => data.to_sym}
        end
      end
      result
    end
  end
  
  class ArgumentLexer
    require 'strscan'

    WHITESPACE_RE = /\s+/m
    NAME_RE = /
      [a-zA-Z_][a-zA-Z0-9_]*
      (:?\.[a-zA-Z0-9][a-zA-Z0-9_-]*)*
    /x
    PIPE_RE = /\|/
    SEPERATOR_RE = /,/
    FILTER_END_RE = /;/
    STRING_RE = /
      (?:
        "([^"\\]*(?:\\.[^"\\]*)*)"
        |
        '([^'\\]*(?:\\.[^'\\]*)*)'
      )
      /xm
    
    NUMBER_RE = /\d+(\.\d*)?/
    OPERATOR_RE = /(:?!|>|<|=|>=|<=|!=|==|=|and|not|or)/
  
    def initialize(argstring, pos = 0)
      @argument = argstring
    end
    
    def self.lex(argstring)
      new(argstring).lexer()
    end
    
    def lexer
      s = StringScanner.new(@argument)
      state = :initial
      result = []
      while ! s.eos?
        next if s.scan(WHITESPACE_RE)
        
        if state == :initial
          if match = s.scan(OPERATOR_RE)
            result << [:operator, match]
          elsif match = s.scan(NAME_RE)
            result << [:name, match]
          elsif match = s.scan(PIPE_RE)
            state = :filter
            result << [:filter_start, nil]
          elsif match = s.scan(SEPERATOR_RE)
            result << [:seperator, nil]
          elsif match = s.scan(STRING_RE)
            result << [:string, match]
          elsif match = s.scan(NUMBER_RE)
            result << [:number, match]
          else 
            raise SyntaxError, "unexpected character #{s.getch} in tag"
          end
        elsif state == :filter
          if match = s.scan(PIPE_RE)
            result << [:filter_end, nil]
            result << [:filter_start, nil]
          elsif match = s.scan(SEPERATOR_RE)
            result << [:seperator, nil]
          elsif match = s.scan(FILTER_END_RE)
            result << [:filter_end, nil]
            state = :initial
          elsif match = s.scan(NAME_RE)
            result << [:name, match]
          elsif match = s.scan(STRING_RE)
            result << [:string, match]
          elsif match = s.scan(NUMBER_RE)
            result << [:number, match]
          else 
            raise SyntaxError, "unexpected character #{s.getch} in filter"
          end
        end
      end
      result << [:filter_end, nil]  if state == :filter

      result
    end
  
  end
end