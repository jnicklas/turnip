module Turnip
  class FeatureFile
    attr_accessor :file_name, :content, :feature_name
    
    def initialize(file_name)
      @file_name = file_name
    end
    
    def feature_name
      @feature_name ||= begin
        file = Pathname.new(file_name).basename.to_s
        file[0...file.index('.feature')]
      end
    end
    
    def content
      @content ||= File.read(file_name)
    end
  end
end