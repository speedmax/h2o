module H2o
  class FileLoader
    attr_accessor :path
    
    def initialize(path)
      raise "Search path not found" unless File.exist?(path)
      
      self.path = Pathname.new(path)
    end

    def read(file)
      raise "Template not found" unless exist?(file)
      File.read(self.path + file)
    end
    
    def exist?(file)
      File.exist?(self.path + file)
    end
  end
end