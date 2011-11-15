module Turnip
  class Builder
    module Tags
      def tags
        @raw.tags.map { |tag| tag.name.sub(/^@/, '') }
      end
      
      def active_tags
        tags.map(&:to_sym)
      end

      def tags_hash
        Hash[tags.map { |t| [t.to_sym, true] }]
      end

      def metadata_hash
        tags_hash
      end
    end

    module Name
      def name
        @raw.name
      end
    end

    class Feature
      include Tags
      include Name

      attr_reader :scenarios, :backgrounds
      attr_accessor :feature_tag

      def initialize(raw)
        @raw = raw
        @scenarios = []
        @backgrounds = []
      end
      
      # Feature's active_tags automatically prepends the :global tag
      # as well as its feature_tag if defined
      def active_tags
        active_tags = [:global]
        active_tags << feature_tag.to_sym if feature_tag
        active_tags + super
      end

      def metadata_hash
        super.merge(:type => Turnip.type, :turnip => true)
      end
    end

    class Background
      attr_reader :steps
      def initialize(raw)
        @raw = raw
        @steps = []
      end
    end

    class Scenario
      include Tags
      include Name

      attr_accessor :steps

      def initialize(raw)
        @raw = raw
        @steps = []
      end
    end

    class ScenarioOutline
      include Tags
      include Name

      attr_reader :steps

      def initialize(raw)
        @raw = raw
        @steps = []
      end

      def to_scenarios(examples)
        rows = examples.rows.map(&:cells)
        headers = rows.shift
        rows.map do |row|
          Scenario.new(@raw).tap do |scenario|
            scenario.steps = steps.map do |step|
              new_description = step.description.gsub(/<([^>]*)>/) { |_| Hash[headers.zip(row)][$1] }
              Step.new(step.keywords, new_description, step.extra_arg)
            end
          end
        end
      end
    end

    class Step < Struct.new(:keywords, :description, :extra_arg)
    end

    attr_reader :features

    class << self
      def build(feature_file)
        Turnip::Builder.new(feature_file).tap do |builder|
          formatter = Gherkin::Formatter::TagCountFormatter.new(builder, {})
          parser = Gherkin::Parser::Parser.new(formatter, true, "root", false)
          lexer = Gherkin::Lexer::I18nLexer.new(parser, false)
          lexer.send(:create_delegate, feature_file.content)
          builder.i18n_language = lexer.i18n_language
          parser.parse(feature_file.content, nil, 0)
        end
      end
    end
    
    attr_accessor :i18n_language, :given_keywords, :when_keywords, :then_keywords, :and_keywords, :but_keywords

    def initialize(feature_file)
      @feature_file = feature_file
      @features = []
    end
    
    def background(background)
      @current_step_context = Background.new(background)
      @current_feature.backgrounds << @current_step_context
    end

    def feature(feature)
      @current_feature = Feature.new(feature)
      # Automatically add a tag based on the name of the feature to the Feature if configured to
      @current_feature.feature_tag = @feature_file.feature_name if Turnip::Config.autotag_features
      @features << @current_feature
    end

    def scenario(scenario)
      @current_step_context = Scenario.new(scenario)
      @current_feature.scenarios << @current_step_context
    end

    def scenario_outline(outline)
      @current_step_context = ScenarioOutline.new(outline)
    end

    def examples(examples)
      @current_feature.scenarios.push(*@current_step_context.to_scenarios(examples))
    end

    def step(step)
      if step.doc_string
        extra_arg = step.doc_string.value
      elsif step.rows
        extra_arg = Turnip::Table.new(step.rows.map { |row| row.cells(&:value) })
      end
      @current_step_context.steps << Step.new(step_keywords(step), step.name, extra_arg)
    end

    def eof
    end
    
    private
    
    def step_keywords(step)
      if i18n_language
        given_keywords ||= i18n_language.keywords(:given).reject{|s| s == "* "}
        when_keywords  ||= i18n_language.keywords(:when).reject{|s| s == "* "}
        then_keywords  ||= i18n_language.keywords(:then).reject{|s| s == "* "}
        and_keywords   ||= i18n_language.keywords(:and).reject{|s| s == "* "}
        but_keywords   ||= i18n_language.keywords(:but).reject{|s| s == "* "}
        
        if given_keywords.include? step.keyword
          return given_keywords
        elsif when_keywords.include? step.keyword
          return when_keywords
        elsif then_keywords.include? step.keyword
          return then_keywords
        elsif and_keywords.include? step.keyword
          @current_step_context.steps.reverse.each do |previous_step|
            if given_keywords == previous_step.keywords
              return and_keywords + given_keywords
            elsif when_keywords == previous_step.keywords
              return and_keywords + when_keywords
            elsif then_keywords == previous_step.keywords
              return and_keywords + then_keywords
            else
              return and_keywords
            end
          end
        elsif but_keywords.include? step.keyword
          @current_step_context.steps.reverse.each do |previous_step|
            if given_keywords == previous_step.keywords
              return but_keywords + given_keywords
            elsif when_keywords == previous_step.keywords
              return but_keywords + when_keywords
            elsif then_keywords == previous_step.keywords
              return but_keywords + then_keywords
            else
              return but_keywords
            end
          end
        end
      end
    end
  end
end
