module H2o
  class Parser 
    attr_reader :token, :env
    attr_accessor :storage
    
    ParseRegex = /
      (.*?)(?:
        #{Regexp.escape(BLOCK_START)}    (.*?)
        #{Regexp.escape(BLOCK_END)}          |
        #{Regexp.escape(VAR_START)}      (.*?)
        #{Regexp.escape(VAR_END)}            |
        #{Regexp.escape(COMMENT_START)}  (.*?)
        #{Regexp.escape(COMMENT_END)}
      ) (?:\r?\n)?
    /xim

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
      @source.scan(ParseRegex).each do |match|
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
          when :text
            nodelist << TextNode.new(content) unless content.empty?
          when :variable
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
          when :block
            name, args = content.split(/\s+/, 2)
            name = name.to_sym
            
            if untils.include?(name)
              return nodelist
            end
            
            tag = Tags[name]
            raise "Unknow tag #{name}" if tag.nil?
            
            nodelist << tag.new(self, args) if tag
          when :comment
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
          when :boolean
            current_buffer << (data == 'true'? true : false)
          when :name
            current_buffer << data.to_sym
          when :number
            current_buffer << (data.include?('.') ? data.to_f : data.to_i)
          when :string
            data.match(STRING_RE)
            current_buffer << ($1 || $2)
          when :named_argument
            current_buffer << {} unless current_buffer.last.is_a?(Hash)
            
            named_args = current_buffer.last
            name, value = data.split(':').map{|m| m.strip}
            named_args[name.to_sym] = parse_arguments(value).first
          when :operator
            # replace exclaimation mark '!' into not
            data = 'not' if data == '!'
            current_buffer << {:operator => data.to_sym}
        end
      end
      result
    end
    
    def pretty_print pp
      nil
    end
  end
  
  class ArgumentLexer
    require 'strscan'

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
          elsif match = s.scan(BOOLEAN_RE)
            result << [:boolean, match]
          elsif match = s.scan(NAMED_ARGS_RE)
            result << [:named_argument, match]
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
          elsif match = s.scan(BOOLEAN_RE)
            result << [:boolean, match]
          elsif match = s.scan(NAMED_ARGS_RE)
            result << [:named_argument, match]
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