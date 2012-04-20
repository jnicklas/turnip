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
      attr_accessor :feature_tag

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
              Step.new(new_description, step.extra_arg)
            end
          end
        end
      end
    end

    class Step < Struct.new(:description, :extra_arg)
    end

    attr_reader :features

    class << self
      def build(feature_file)
        Turnip::Builder.new.tap do |builder|
          formatter = Gherkin::Formatter::TagCountFormatter.new(builder, {})
          parser = Gherkin::Parser::Parser.new(formatter, true, "root", false)
          parser.parse(File.read(feature_file), nil, 0)
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
      @current_step_context.steps << Step.new(step.name, extra_arg)
    end

    def eof
    end
  end
end
