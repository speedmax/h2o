module H2o
  class Stream < Array
    def << (item)
      unshift item.to_s
    end
    
    def close
      reverse!
    end
  end
end