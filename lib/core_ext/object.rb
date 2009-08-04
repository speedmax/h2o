class Object
  def self.h2o_expose(*attrs)
    @h2o_safe = attrs
  end
  
  def self.h2o_safe_methods
    @h2o_safe
  end
  
  def to_h2o
    self
  end
end