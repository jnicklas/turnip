module Turnip
  class Builder
    module Tags
      def tags
        @raw.tags.map { |tag| tag.name.sub(/^@/, '') }
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

      def initialize(raw)
        @raw = raw
        @scenarios = []
        @backgrounds = []
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

      attr_reader :steps

      def initialize(raw)
        @raw = raw
        @steps = []
      end
    end

    class Step
      include Name

      def initialize(raw)
        @raw = raw
      end
    end

    attr_reader :features

    class << self
      def build(content)
        Turnip::Builder.new.tap do |builder|
          formatter = Gherkin::Formatter::TagCountFormatter.new(builder, {})
          parser = Gherkin::Parser::Parser.new(formatter, true, "root", false)
          parser.parse(content, nil, 0)
        end
      end
    end

    def initialize
      @features = []
    end

    def background(background)
      @current_step_context = Background.new(background)
      @current_feature.backgrounds << @current_step_context
    end

    def feature(feature)
      @current_feature = Feature.new(feature)
      @features << @current_feature
    end

    def scenario(scenario)
      @current_step_context = Scenario.new(scenario)
      @current_feature.scenarios << @current_step_context
    end

    def step(step)
      @current_step = Step.new(step)
      @current_step_context.steps << @current_step
    end

    def eof
    end
  end
end
