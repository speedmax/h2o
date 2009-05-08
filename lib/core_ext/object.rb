class Object
  def self.h2o_safe(*attrs)
    @h2o_safe = attrs
  end
  
  def self.h2o_safe_methods
    @h2o_safe
  end
  
end