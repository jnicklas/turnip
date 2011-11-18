module Turnip
  class StepKeywordFinder    
    def initialize(i18n_language)
      @i18n_language = i18n_language
      parse_language_keywords
    end
    
    def step_keywords(keyword, previous_step_keywords=[])
      if @given_keywords.include? keyword
        return @given_keywords
      elsif @when_keywords.include? keyword
        return @when_keywords
      elsif @then_keywords.include? keyword
        return @then_keywords
      elsif @and_keywords.include? keyword
        return @and_keywords + most_recent_primary_keywords(previous_step_keywords)
      elsif @but_keywords.include? keyword
        return @but_keywords + most_recent_primary_keywords(previous_step_keywords)
      end
    end
    
    private
    
    # Grab the language keywords defined for the various step keywords
    def parse_language_keywords
      @given_keywords = @i18n_language.keywords(:given).reject{|s| s == "* "}
      @when_keywords  = @i18n_language.keywords(:when).reject{|s| s == "* "}
      @then_keywords  = @i18n_language.keywords(:then).reject{|s| s == "* "}
      @and_keywords   = @i18n_language.keywords(:and).reject{|s| s == "* "}
      @but_keywords   = @i18n_language.keywords(:but).reject{|s| s == "* "}
    end
    
    def primary_keywords
      @given_keywords + @when_keywords + @then_keywords
    end
    
    def most_recent_primary_keywords(previous_step_keywords=[])
      previous_step_keywords.reverse.each do |previous_keywords|
        return previous_keywords if (primary_keywords & previous_keywords).any?
      end
      return []
    end
  end
end