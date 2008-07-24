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
      self.parse()
    end

    def parse
      result = []
      
      @source.scan(TAG_REGEX).each do |match|
        result << [:text, match[0]] if match[0] and !match[0].empty?
      end
      
      rest = ($~ != nil) ? @source[$~.end(0) .. -1] : @source
      
      if rest
        result << [:text, rest]
      end
      
      puts rest.inspect
    end
    
    def parse_until
    end
    
    
    def tokenize
    end
    
    def self.parse_arguments
    end
    
  end
  
  class Lexer
    
  end
  
  class ArgumentLexer
    
  end
end