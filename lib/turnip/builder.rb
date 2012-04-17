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

      def initialize(raw, feature_file)
        @raw = raw
        @feature_file = feature_file
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
        loc = "#{@feature_file.file_name}:0"
        super.merge(:type => Turnip.type, :turnip => true, :caller => [loc])
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
        Turnip::Builder.new(feature_file).tap do |builder|
          formatter = Gherkin::Formatter::TagCountFormatter.new(builder, {})
          parser = Gherkin::Parser::Parser.new(formatter, true, "root", false)
          parser.parse(feature_file.content, nil, 0)
        end
      end
    end

    def initialize(feature_file)
      @feature_file = feature_file
      @features = []
    end

    def background(background)
      @current_step_context = Background.new(background)
      @current_feature.backgrounds << @current_step_context
    end

    def feature(feature)
      @current_feature = Feature.new(feature, @feature_file)

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
      @current_step_context.steps << Step.new(step.name, extra_arg)
    end

    def eof
    end
  end
end
