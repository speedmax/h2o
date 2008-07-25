module H2o
  class Parser 
    TAG_REGEX = /
      (.*?)(?:
        #{Regexp.escape(Constants::BLOCK_START)}    (.*?)
        #{Regexp.escape(Constants::BLOCK_END)}          |
        #{Regexp.escape(Constants::VAR_START)}      (.*?)
        #{Regexp.escape(Constants::VAR_END)}            |
        #{Regexp.escape(Constants::COMMENT_START)}  (.*?)
        #{Regexp.escape(Constants::COMMENT_END)}
      )
    /xim

    def initialize (source, filename)
      @source = source
      @filename = filename
      @tokenstream = tokenize
      @nodelist = parse
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
      result
    end
    
    def parse(*untils)
      @tokenstream.each do |token|
        
      end
    end
    
    def parse_until(*args); end
    
    
    def self.parse_arguments; end
  end
  
  class Lexer
    
  end
  
  class ArgumentLexer
    
  end
end