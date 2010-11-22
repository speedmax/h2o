module DefaultFilters
  
  # String filters
  def upper string
    string.to_s.upcase
  end
  
  def lower string
    string.to_s.downcase
  end
  
  def capitalize string
    string.to_s.capitalize
  end

  def escape string, attribute=false
    string = string.dup.to_s

    {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;'
    }.each do |v, k|
      string.tr!(v, k)
    end
    
    string.gsub!(/"/, '&quot;') if attribute

    string
  end

  # Array Filters
  def join(list, delimiter=', ')
    list.join(delimiter)
  end

  def first(list)
    list.first
  end

  def last(list)
    list.last
  end

  def contain(object, item)
    object.include?(item)
  end

  H2o::Filters << self
end